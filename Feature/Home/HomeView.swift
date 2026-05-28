//
//  HomeView.swift
//  StandWise
//
//  Created by Aura Jatra on 22/05/26.
//

import SwiftData
import SwiftUI
import UIKit

struct HomeView: View {
    let user: User
    @Binding var shouldOpenPainLog: Bool
    @Query(sort: \PainLogEntry.logTime, order: .reverse) private var painLogEntries: [PainLogEntry]

    @AppStorage("lastCautionNotificationDay") private var lastCautionNotificationDay = ""
    @AppStorage("warningAcknowledgedDay") private var warningAcknowledgedDay = ""
    @AppStorage("warningSnoozeMinutes") private var warningSnoozeMinutes = 14
    @AppStorage("activityCardImpacts") private var storedActivityImpacts = Data()
    @AppStorage("activityCardManualActivities") private var storedManualActivities = Data()

    @State private var isShowingSnooze = false
    @State private var healthManager = HealthManager()
    @State private var notificationEventManager = EventManager()

    private let brandGreen = Color(red: 0.05, green: 0.48, blue: 0.22)
    private let cautionRed = Color(.systemRed)
    private let cautionYellow = Color(.systemYellow)

    private var stepProgress: Double {
        Double(healthManager.todaySteps) / Double(max(user.maxFootLoad, 1))
    }

    private var standingProgress: Double {
        Double(healthManager.todayStandingMinutes) / Double(8 * 60)
    }

    private var loadProgress: Double {
        max(stepProgress, standingProgress)
    }

    private var loadStatus: FootLoadStatus {
        switch loadProgress {
        case 1.0...:
            .warning
        case 0.7..<1.0:
            .caution
        default:
            .safe
        }
    }

    private var standingTimeText: String {
        formattedDuration(minutes: healthManager.todayStandingMinutes)
    }

    private var restTimeText: String {
        formattedDuration(minutes: max(0, 8 * 60 - healthManager.todayStandingMinutes))
    }

    private var todaysPainLogCount: Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return painLogEntries.filter { $0.logTime >= startOfDay }.count
    }

    private var todaysPainLogCountText: String {
        todaysPainLogCount == 1 ? "1 entry" : "\(todaysPainLogCount) entries"
    }

    private var nonActiveTimeText: String {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let components = calendar.dateComponents([.minute], from: startOfDay, to: now)
        let totalMinutesPassed = components.minute ?? 0
        let excludedMinutes = healthManager.todayStandingMinutes + healthManager.todaySleepMinutes
        let nonActiveMinutes = max(0, totalMinutesPassed - excludedMinutes)

        return formattedDuration(minutes: nonActiveMinutes)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                background

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        profileHeader
                        statusWidget
                        statsSection
                        ActivityCard()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }

                Color(.systemBackground)
                    .frame(height: proxy.safeAreaInsets.top)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $shouldOpenPainLog) {
            PainLogView()
        }
        .sheet(isPresented: $isShowingSnooze) {
            SnoozeView { minutes in
                Task {
                    await scheduleWarningReminder(
                        after: minutes,
                        hasHighImpactActivityAhead: upcomingHighImpactActivityTitle() != nil
                    )
                }
            }
                .presentationDetents([.height(460)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(.systemBackground))
        }
        .task {
            await healthManager.requestAuthorizationAndFetchTodayMetrics()
            await notificationEventManager.refreshTodayActivities()
            await evaluateNotifications()
        }
        .onChange(of: healthManager.todaySteps) {
            Task {
                await evaluateNotifications()
            }
        }
        .onChange(of: healthManager.todayStandingMinutes) {
            Task {
                await evaluateNotifications()
            }
        }
        .onChange(of: storedActivityImpacts) {
            Task {
                await evaluateNotifications()
            }
        }
        .onChange(of: storedManualActivities) {
            Task {
                await evaluateNotifications()
            }
        }
    }

    private var background: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }

    private var profileHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    Text("Hello, ")
                        .font(.title)
                        .fontWeight(.regular)

                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                }

                Text("Let's keep your activity in balance today.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            profileImage
        }
    }

    @ViewBuilder
    private var profileImage: some View {
        if let profileImageData = user.profileImageData,
           let uiImage = UIImage(data: profileImageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                }
                .accessibilityLabel("Profile picture")
        } else {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 52))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.black)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var statusWidget: some View {
        switch loadStatus {
        case .warning:
            footStatusWidget(
                eyebrow: "YOUR FEET ARE CURRENTLY",
                title: "You have exceeded your safe limit.",
                message: "Take a short rest now to reduce the risk of a flare-up.",
                badgeTitle: "WARNING",
                badgeColor: cautionRed,
                background: warningBackground,
                status: .warning
            )
        case .caution:
            footStatusWidget(
                eyebrow: "YOUR FEET NEED CAUTION",
                title: "You are getting close to your limit.",
                message: "Plan your next rest before your schedule gets heavier.",
                badgeTitle: "CAUTION",
                badgeColor: cautionYellow,
                background: cautionBackground,
                status: .caution
            )
        case .safe:
            footStatusWidget(
                eyebrow: "YOUR FEET ARE SAFE",
                title: "You are within today's safe range.",
                message: "Keep balancing movement with recovery throughout the day.",
                badgeTitle: "SAFE",
                badgeColor: brandGreen,
                background: safeBackground,
                status: .safe
            )
        }
    }

    private func footStatusWidget<Background: View>(
        eyebrow: String,
        title: String,
        message: String,
        badgeTitle: String,
        badgeColor: Color,
        background: Background,
        status: FootLoadStatus
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(eyebrow)
                    .font(.caption.weight(.bold))

                Spacer(minLength: 12)

                Text(Date.now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                    .font(.caption)
            }
            .foregroundStyle(.primary)

            statusBadge(title: badgeTitle, color: badgeColor)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(badgeColor)
                    .fixedSize(horizontal: false, vertical: true)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if status == .warning {
                statusActions(tint: badgeColor, status: status)
            }

            painLogLink
        }
        .padding(24)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.10), radius: 10, y: 5)
    }

    private func statusActions(tint: Color, status: FootLoadStatus) -> some View {
        HStack(spacing: 12) {
            Button {
                acknowledgeStatus(status)
            } label: {
                Text("OK")
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .tint(tint)
            .clipShape(Capsule())

            if status == .warning {
                Button {
                    isShowingSnooze = true
                } label: {
                    Text("Still Busy")
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 6)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .tint(Color(.systemGray))
                .clipShape(Capsule())
            }
        }
    }

    private var painLogLink: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Today's Pain Logs")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(todaysPainLogCountText)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)

                Label("Edit", systemImage: "pencil.line")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            NavigationLink {
                PainLogView()
            } label: {
                Text("Log Pain")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color(.systemBackground), in: Capsule())
                    .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Open pain log")
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 1)
        }
    }

    private func statusBadge(title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 13, height: 13)

                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
            }

            Text(title)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.25))
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.30), lineWidth: 1)
                }
        )
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            statItem(icon: "figure.walk", value: healthManager.todaySteps.formatted(), label: "Steps")

            statDivider

            statItem(icon: "figure.stand", value: standingTimeText, label: "Standing")

            statDivider

            statItem(icon: "sofa.fill", value: nonActiveTimeText, label: "Rest")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(brandGreen)
                .frame(width: 44, height: 44)
                .background(brandGreen.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(spacing: 0) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1, height: 64)
    }

    private var warningBackground: some View {
        Color("WarningGradientMiddle")
    }

    private var cautionBackground: some View {
        Color(.systemYellow).opacity(0.18)
    }

    private var safeBackground: some View {
        brandGreen.opacity(0.12)
    }

    private func formattedDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(remainingMinutes)m"
        }
    }

    private func evaluateNotifications() async {
        await notificationEventManager.refreshTodayActivities()
        let highImpactActivityTitle = upcomingHighImpactActivityTitle()

        switch loadStatus {
        case .safe:
            StandWiseNotificationManager.cancelWarningReminder()
        case .caution:
            await sendCautionNotificationIfNeeded(highImpactActivityTitle: highImpactActivityTitle)
            StandWiseNotificationManager.cancelWarningReminder()
        case .warning:
            await scheduleWarningReminder(
                after: warningSnoozeMinutes,
                hasHighImpactActivityAhead: highImpactActivityTitle != nil
            )
        }
    }

    private func sendCautionNotificationIfNeeded(highImpactActivityTitle: String?) async {
        let today = notificationDayKey
        let notificationKey = highImpactActivityTitle == nil ? "\(today)-standard" : "\(today)-high-impact"

        guard lastCautionNotificationDay != notificationKey else {
            return
        }

        lastCautionNotificationDay = notificationKey
        await StandWiseNotificationManager.sendCautionNotification(
            standingMinutes: healthManager.todayStandingMinutes,
            highImpactActivityTitle: highImpactActivityTitle,
            stepCapacityUsed: stepProgress
        )
    }

    private func scheduleWarningReminder(after minutes: Int, hasHighImpactActivityAhead: Bool) async {
        guard warningAcknowledgedDay != notificationDayKey else {
            return
        }

        await StandWiseNotificationManager.scheduleWarningReminder(
            after: minutes,
            hasHighImpactActivityAhead: hasHighImpactActivityAhead
        )
    }

    private func upcomingHighImpactActivityTitle() -> String? {
        let now = Date()
        let manualActivities = decodedManualActivities()
        let activityImpacts = decodedActivityImpacts()

        let upcomingManualActivities = manualActivities.compactMap { activity -> (title: String, startDate: Date)? in
            guard activity.startDate > now && activity.impact == .high else {
                return nil
            }

            return (activity.title, activity.startDate)
        }

        let upcomingCalendarActivities = notificationEventManager.todayActivities.compactMap { activity -> (title: String, startDate: Date)? in
            guard activity.startDate > now && activityImpacts[activity.id, default: .mid] == .high else {
                return nil
            }

            return (activity.title, activity.startDate)
        }

        return (upcomingManualActivities + upcomingCalendarActivities)
            .sorted { $0.startDate < $1.startDate }
            .first?
            .title
    }

    private func decodedManualActivities() -> [ActivityItem] {
        (try? JSONDecoder().decode([ActivityItem].self, from: storedManualActivities)) ?? []
    }

    private func decodedActivityImpacts() -> [String: ActivityImpact] {
        (try? JSONDecoder().decode([String: ActivityImpact].self, from: storedActivityImpacts)) ?? [:]
    }

    private func acknowledgeStatus(_ status: FootLoadStatus) {
        if status == .warning {
            warningAcknowledgedDay = notificationDayKey
            StandWiseNotificationManager.cancelWarningReminder()
        }
    }

    private var notificationDayKey: String {
        Self.dayFormatter.string(from: Date())
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

private enum FootLoadStatus {
    case safe
    case caution
    case warning
}

private struct ActivityRow: View {
    let item: ActivityItem

    var body: some View {
        HStack(spacing: 14) {
            Text(item.time)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 84, alignment: .leading)

            Text(item.title)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(item.impact.rawValue)
                .font(.caption2.weight(.bold))
                .foregroundStyle(item.impact.foregroundColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(item.impact.color)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

private struct ActivityDetailPlaceholder: View {
    let item: ActivityItem

    var body: some View {
        ContentUnavailableView {
            Label(item.title, systemImage: "figure.walk")
        } description: {
            Text("Activity details will appear here.")
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("home") {
    NavigationStack {
        HomeView(
            user: User(name: "User", footCondition: .moderate, standCondition: .mild),
            shouldOpenPainLog: .constant(false)
        )
            .modelContainer(for: [User.self, PainLogEntry.self], inMemory: true)
    }
}
