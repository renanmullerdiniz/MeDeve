import SwiftUI

struct DebtRowView: View {

    let iou: IOU

    var body: some View {
        HStack(alignment: .center, spacing: 14) {

            // Embarrassment indicator
            EmbarrassmentBadge(level: iou.embarrassmentLevel)

            // Name + note + date
            VStack(alignment: .leading, spacing: 3) {
                Text(iou.wrappedPersonName)
                    .font(.headline)
                    .foregroundColor(.primary)

                if !iou.wrappedNote.isEmpty {
                    Text(iou.wrappedNote)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Text(shortDate(iou.wrappedCreatedAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Amount + days elapsed + WhatsApp shortcut
            VStack(alignment: .trailing, spacing: 4) {
                Text(iou.formattedAmount)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(elapsedLabel(iou.daysSinceCreation))
                    .font(.caption2)
                    .foregroundColor(elapsedColor(iou.embarrassmentLevel))

                Button(action: {
                    WhatsAppHelper.sendReminder(to: iou.wrappedPersonName, amount: iou.amount)
                }) {
                    Image(systemName: "message.fill")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityLabel("Cobrar \(iou.wrappedPersonName) via WhatsApp")
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Helpers

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale    = Locale(identifier: "pt_BR")
        f.dateStyle = .short
        f.timeStyle = .none
        return f.string(from: date)
    }

    private func elapsedLabel(_ days: Int) -> String {
        switch days {
        case 0:      return "hoje"
        case 1:      return "1 dia"
        default:     return "\(days) dias"
        }
    }

    private func elapsedColor(_ level: EmbarrassmentLevel) -> Color {
        switch level {
        case .recent:   return .green
        case .overdue:  return .orange
        case .critical: return .red
        }
    }
}

struct DebtRowView_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceController.preview.container.viewContext
        let iou = IOU(context: ctx)
        iou.id          = UUID()
        iou.personName  = "Carlos Lima"
        iou.amount      = 120.50
        iou.note        = "Festa da firma"
        iou.createdAt   = Calendar.current.date(byAdding: .day, value: -12, to: Date())
        iou.isPaid      = false

        return DebtRowView(iou: iou)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
