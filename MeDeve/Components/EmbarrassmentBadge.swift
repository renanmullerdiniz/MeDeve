import SwiftUI

/// Indicador colorido de "vergonha" baseado em quantos dias se passaram.
/// Verde = recente (<7d), Amarelo = atrasado (7–29d), Vermelho = crítico (30+d)
struct EmbarrassmentBadge: View {

    let level: EmbarrassmentLevel

    var color: Color {
        switch level {
        case .recent:   return .green
        case .overdue:  return Color(.systemOrange)
        case .critical: return .red
        }
    }

    var accessibilityText: String {
        switch level {
        case .recent:   return "Recente"
        case .overdue:  return "Atrasado"
        case .critical: return "Crítico — já faz mais de um mês"
        }
    }

    var labelText: String {
        switch level {
        case .recent:   return "recente"
        case .overdue:  return "atrasado"
        case .critical: return "esqueceu\nmesmo"
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 20, height: 20)

                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            }
            Text(labelText)
                .font(.caption2)
                .foregroundColor(color)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement()
        .accessibilityLabel(accessibilityText)
    }
}

struct EmbarrassmentBadge_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 24) {
            EmbarrassmentBadge(level: .recent)
            EmbarrassmentBadge(level: .overdue)
            EmbarrassmentBadge(level: .critical)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
