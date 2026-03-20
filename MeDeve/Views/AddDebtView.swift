import SwiftUI

struct AddDebtView: View {

    @ObservedObject var viewModel: IOUViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var personName = ""
    @State private var amountText = ""
    @State private var note       = ""

    private var parsedAmount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }

    private var isFormValid: Bool {
        !personName.trimmingCharacters(in: .whitespaces).isEmpty &&
        (parsedAmount ?? 0) > 0
    }

    var body: some View {
        NavigationView {
            List {
                // Pessoa
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quem te deve?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    TextField("Nome da pessoa", text: $personName)
                        .autocapitalization(.words)
                        .disableAutocorrection(false)
                }
                .padding(.vertical, 4)

                // Valor
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quanto?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    HStack {
                        Text("R$")
                            .foregroundColor(.secondary)
                        TextField("0,00", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                }
                .padding(.vertical, 4)

                // Motivo
                VStack(alignment: .leading, spacing: 6) {
                    Text("Por quê? (opcional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    TextField("Motivo", text: $note)
                    Text("Ex: churrasco, vaquinha, rolê...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Registrar Dívida")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveDebt) {
                        Text("Salvar")
                            .fontWeight(.semibold)
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Save

    private func saveDebt() {
        guard let amount = parsedAmount, amount > 0 else { return }

        viewModel.addIOU(
            personName: personName.trimmingCharacters(in: .whitespaces),
            amount: amount,
            note: note
        )

        presentationMode.wrappedValue.dismiss()
    }
}

struct AddDebtView_Previews: PreviewProvider {
    static var previews: some View {
        AddDebtView(
            viewModel: IOUViewModel(
                context: PersistenceController.preview.container.viewContext
            )
        )
    }
}
