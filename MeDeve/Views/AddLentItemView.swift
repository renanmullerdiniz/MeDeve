import SwiftUI

struct AddLentItemView: View {

    @ObservedObject var viewModel: LentItemViewModel
    @Environment(\.presentationMode) private var presentationMode

    @State private var personName = ""
    @State private var itemName   = ""
    @State private var note       = ""

    private var isFormValid: Bool {
        !personName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !itemName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            List {
                // Pessoa
                VStack(alignment: .leading, spacing: 6) {
                    Text("Quem está com o item?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    TextField("Nome da pessoa", text: $personName)
                        .autocapitalization(.words)
                        .disableAutocorrection(false)
                }
                .padding(.vertical, 4)

                // Item
                VStack(alignment: .leading, spacing: 6) {
                    Text("O que você emprestou?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    TextField("Nome do item", text: $itemName)
                        .autocapitalization(.sentences)
                    Text("Ex: camiseta, jogo, livro, fone...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)

                // Observação
                VStack(alignment: .leading, spacing: 6) {
                    Text("Observação (opcional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    TextField("Detalhe adicional", text: $note)
                    Text("Ex: cor, tamanho, ocasião...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Novo Empréstimo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveItem) {
                        Text("Salvar")
                            .fontWeight(.semibold)
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    // MARK: - Save

    private func saveItem() {
        viewModel.addLentItem(
            personName: personName.trimmingCharacters(in: .whitespaces),
            itemName: itemName.trimmingCharacters(in: .whitespaces),
            note: note
        )
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddLentItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddLentItemView(
            viewModel: LentItemViewModel(
                context: PersistenceController.preview.container.viewContext
            )
        )
    }
}
