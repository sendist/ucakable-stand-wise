//
//  PainLogView.swift
//  StandWise
//
//  Created by Chusen Kamaludin on 22/05/26.
//

import SwiftUI

struct PainLogView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedLocation = "Heel"
    @State private var selectedSeverity = 3
    @State private var selectedContexts: Set<String> = []

    private let painLocations = ["Heel", "Arch", "Ball of Foot", "Toes"]
    private let contextOptions = ["Just started", "Been hurting a while", "After sitting down"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    painLocationSection
                    severitySection
                    contextSection
                    infoBox
                    saveButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Pain Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .accessibilityLabel("Back")
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Foot Pain Log")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Log your foot pain. The more honest, the smarter the app gets.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var painLocationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Where does it hurts?")

            FlowLayout(horizontalSpacing: 10, verticalSpacing: 12) {
                ForEach(painLocations, id: \.self) { location in
                    SelectableChip(
                        title: location,
                        isSelected: selectedLocation == location
                    ) {
                        selectedLocation = location
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var severitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Pain Severity")

            SeveritySelector(selectedSeverity: $selectedSeverity)
        }
    }

    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Context (Optional)")

            VStack(spacing: 10) {
                ForEach(contextOptions, id: \.self) { option in
                    SelectableChip(
                        title: option,
                        isSelected: selectedContexts.contains(option),
                        fillsWidth: true
                    ) {
                        toggleContext(option)
                    }
                }
            }
        }
    }

    private var infoBox: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 2)

            Text("Past 4h: 5,200 steps • 3.5h standing • 1 heavy event (Site Visit, 2 PM). Likely trigger: prolonged standing.")
                .font(.footnote)
                .foregroundStyle(Color(.darkGray))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var saveButton: some View {
        Button {
            // Presentation only. Persistence will be added with reminder logic later.
        } label: {
            Text("Save Pain Log")
                .font(.headline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
        }
        .background(Color.blue, in: Capsule())
        .shadow(color: Color.blue.opacity(0.22), radius: 12, x: 0, y: 6)
        .buttonStyle(.plain)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline.bold())
            .foregroundStyle(.primary)
    }

    private func toggleContext(_ option: String) {
        if selectedContexts.contains(option) {
            selectedContexts.remove(option)
        } else {
            selectedContexts.insert(option)
        }
    }
}

private struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    var fillsWidth = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if fillsWidth {
                    Spacer(minLength: 12)

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.body)
                        .foregroundStyle(isSelected ? .white : .secondary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .frame(maxWidth: fillsWidth ? .infinity : nil, alignment: .leading)
            .background(chipBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(chipBorder)
            .shadow(color: isSelected ? Color.blue.opacity(0.18) : Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var chipBackground: some ShapeStyle {
        isSelected ? Color.blue : Color(.systemBackground)
    }

    private var chipBorder: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(isSelected ? Color.blue : Color(.separator).opacity(0.35), lineWidth: 1)
    }
}

private struct FlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        var currentLineWidth: CGFloat = 0
        var currentLineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var widestLine: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let spacing = currentLineWidth == 0 ? 0 : horizontalSpacing

            if currentLineWidth > 0 && currentLineWidth + spacing + size.width > maxWidth {
                totalHeight += currentLineHeight + verticalSpacing
                widestLine = max(widestLine, currentLineWidth)
                currentLineWidth = size.width
                currentLineHeight = size.height
            } else {
                currentLineWidth += spacing + size.width
                currentLineHeight = max(currentLineHeight, size.height)
            }
        }

        totalHeight += currentLineHeight
        widestLine = max(widestLine, currentLineWidth)

        return CGSize(width: proposal.width ?? widestLine, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var currentLineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let spacing = currentX == bounds.minX ? 0 : horizontalSpacing

            if currentX > bounds.minX && currentX + spacing + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += currentLineHeight + verticalSpacing
                currentLineHeight = 0
            }

            subview.place(
                at: CGPoint(x: currentX == bounds.minX ? currentX : currentX + spacing, y: currentY),
                proposal: ProposedViewSize(size)
            )

            currentX = currentX == bounds.minX ? currentX + size.width : currentX + spacing + size.width
            currentLineHeight = max(currentLineHeight, size.height)
        }
    }
}

private struct SeveritySelector: View {
    @Binding var selectedSeverity: Int

    private let options = [
        SeverityOption(value: 1, label: "Barely"),
        SeverityOption(value: 2, label: "Mild"),
        SeverityOption(value: 3, label: "Moderate"),
        SeverityOption(value: 4, label: "Bad"),
        SeverityOption(value: 5, label: "Severe")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { option in
                Button {
                    selectedSeverity = option.value
                } label: {
                    VStack(spacing: 5) {
                        Text("\(option.value)")
                            .font(.headline.bold())
                        Text(option.label)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundStyle(selectedSeverity == option.value ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(background(for: option), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(border(for: option))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(option.value) \(option.label)")
                .accessibilityAddTraits(selectedSeverity == option.value ? .isSelected : [])
            }
        }
        .padding(6)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func background(for option: SeverityOption) -> Color {
        selectedSeverity == option.value ? .blue : Color(.systemBackground)
    }

    private func border(for option: SeverityOption) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(selectedSeverity == option.value ? Color.blue : Color.clear, lineWidth: 1)
    }
}

private struct SeverityOption: Identifiable {
    let value: Int
    let label: String

    var id: Int { value }
}

#Preview {
    PainLogView()
}
