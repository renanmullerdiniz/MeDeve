import Foundation

#if canImport(UIKit)
import UIKit
#endif

struct WhatsAppHelper {

    static func sendReminder(to name: String, amount: Double) {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "pt_BR")
        let amountFormatted = f.string(from: NSNumber(value: amount)) ?? "R$ \(amount)"

        let firstName = name.components(separatedBy: " ").first ?? name

        let message = """
        Oi \(firstName)! 😊 Lembrei que você ainda me deve \(amountFormatted). \
        Sem pressa, mas quando puder acertar me avisa! 🙏
        """

        open(message: message)
    }

    static func sendItemReminder(to name: String, itemName: String) {
        let firstName = name.components(separatedBy: " ").first ?? name

        let message = """
        Oi \(firstName)! 😊 Lembrei que você ainda está com \(itemName) que te emprestei. \
        Quando puder me devolver me avisa! 🙏
        """

        open(message: message)
    }

    // MARK: - Private

    private static func open(message: String) {
        guard let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let whatsappURL = URL(string: "whatsapp://send?text=\(encoded)") else { return }

        #if canImport(UIKit)
        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
        }
        #endif
    }
}
