//
//  ActivityCard.swift
//  StandWise
//
//  Created by Sendi Setiawan on 20/05/26.
//

import SwiftUI

struct ActivityCard: View {
    @State private var eventManager = EventManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Today Activities", systemImage: "calendar")
                    .font(.headline)

                Spacer()

                Button {
                    Task {
                        if eventManager.hasCalendarAccess {
                            await eventManager.refreshTodayActivities()
                        } else {
                            await eventManager.requestAuthorizationAndFetchTodayActivities()
                        }
                    }
                } label: {
                    Image(systemName: eventManager.hasCalendarAccess ? "arrow.clockwise" : "calendar.badge.plus")
                }
                .buttonStyle(.borderless)
                .disabled(eventManager.isLoading)
                .accessibilityLabel(eventManager.hasCalendarAccess ? "Refresh calendar activities" : "Allow calendar access")
            }

            if eventManager.hasCalendarAccess {
                activityList
            } else {
                calendarPermissionPrompt
            }

            if let errorMessage = eventManager.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .task {
            await eventManager.refreshTodayActivities()
        }
    }

    private var calendarPermissionPrompt: some View {
        VStack(alignment: .leading, spacing: 12) {
            if eventManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Calendar")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("Allow access to show today's activity list")
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button {
                Task {
                    await eventManager.requestAuthorizationAndFetchTodayActivities()
                }
            } label: {
                Label("Allow Calendar Access", systemImage: "calendar.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(eventManager.isLoading)
        }
    }

    @ViewBuilder
    private var activityList: some View {
        if eventManager.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if eventManager.todayActivities.isEmpty {
            Text("No calendar activities today")
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 10) {
                ForEach(eventManager.todayActivities) { activity in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: activity.isAllDay ? "sun.max" : "clock")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(activity.title)
                                .font(.subheadline.weight(.semibold))
                            Text(activity.timeRangeText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(activity.calendarTitle)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }

                        Spacer()
                    }
                }
            }
        }
    }
}
