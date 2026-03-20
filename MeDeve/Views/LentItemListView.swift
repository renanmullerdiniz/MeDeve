import SwiftUI
import CoreData

struct LentItemListView: View {

    @StateObject private var viewModel: LentItemViewModel
    @State private var showingAddItem = false

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: LentItemViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if viewModel.lentItems.isEmpty {
                    emptyStateView
                } else {
                    itemList
                }
            }
            .navigationTitle("Empréstimos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Adicionar empréstimo")
                }
            }
            .sheet(isPresented: $showingAddItem, onDismiss: viewModel.fetchLentItems) {
                AddLentItemView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tshirt.fill")
                .font(.system(size: 72))
                .foregroundColor(.blue)

            Text("Nenhum item emprestado!")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Toque em + para registrar um empréstimo.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    // MARK: - List

    private var itemList: some View {
        List {
            Section {
                ForEach(viewModel.lentItems, id: \.id) { item in
                    LentItemRowView(item: item)
                        .contextMenu {
                            Button(action: {
                                withAnimation { viewModel.markAsReturned(item) }
                            }) {
                                Label("Marcar como Devolvido", systemImage: "checkmark.circle.fill")
                            }

                            Button(action: {
                                WhatsAppHelper.sendItemReminder(
                                    to: item.wrappedPersonName,
                                    itemName: item.wrappedItemName
                                )
                            }) {
                                Label("Cobrar via WhatsApp", systemImage: "message.fill")
                            }

                            Button(action: {
                                withAnimation { viewModel.delete(item) }
                            }) {
                                Label("Apagar", systemImage: "trash.fill")
                            }
                        }
                }
                .onDelete { offsets in
                    withAnimation { viewModel.delete(at: offsets) }
                }
            } header: {
                itemCountHeader
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var itemCountHeader: some View {
        HStack {
            Text("\(viewModel.lentItems.count) item\(viewModel.lentItems.count == 1 ? "" : "s") emprestado\(viewModel.lentItems.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .textCase(nil)
    }
}

struct LentItemListView_Previews: PreviewProvider {
    static var previews: some View {
        LentItemListView(context: PersistenceController.preview.container.viewContext)
    }
}
