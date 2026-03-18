import SwiftUI

struct LentItemRowView: View {

    let item: LentItem

    var body: some View {
        HStack(alignment: .center, spacing: 14) {

            // Embarrassment indicator
            EmbarrassmentBadge(level: item.embarrassmentLevel)

            // Name + item + note + date
            VStack(alignment: .leading, spacing: 3) {
                Text(item.wrappedPersonName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(item.wrappedItemName)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                if !item.wrappedNote.isEmpty {
                    Text(item.wrappedNote)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Text(shortDate(item.wrappedCreatedAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Days elapsed + WhatsApp shortcut
            VStack(alignment: .trailing, spacing: 4) {
                Text(elapsedLabel(item.daysSinceCreation))
                    .font(.caption2)
                    .foregroundColor(elapsedColor(item.embarrassmentLevel))

                Button(action: {
                    WhatsAppHelper.sendItemReminder(to: item.wrappedPersonName, itemName: item.wrappedItemName)
                }) {
                    Image(systemName: "message.fill")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                .buttonStyle(BorderlessButtonStyle())
                .accessibilityLabel("Cobrar \(item.wrappedPersonName) via WhatsApp")
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
        case 0:  return "hoje"
        case 1:  return "1 dia"
        default: return "\(days) dias"
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

struct LentItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceController.preview.container.viewContext
        let item = LentItem(context: ctx)
        item.id         = UUID()
        item.personName = "Mariana Souza"
        item.itemName   = "Camiseta azul"
        item.note       = "Show do fim de semana"
        item.createdAt  = Calendar.current.date(byAdding: .day, value: -15, to: Date())
        item.isReturned = false

        return LentItemRowView(item: item)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
