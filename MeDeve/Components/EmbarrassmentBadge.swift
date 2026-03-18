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

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 20, height: 20)

            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
        }
        .accessibilityElement()
        .accessibilityLabel(accessibilityText)
    }
}

struct EmbarrassmentBadge_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 24) {
            VStack {
                EmbarrassmentBadge(level: .recent)
                Text("Recente").font(.caption2)
            }
            VStack {
                EmbarrassmentBadge(level: .overdue)
                Text("Atrasado").font(.caption2)
            }
            VStack {
                EmbarrassmentBadge(level: .critical)
                Text("Crítico").font(.caption2)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
