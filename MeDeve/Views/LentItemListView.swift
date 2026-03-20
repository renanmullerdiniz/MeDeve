import SwiftUI
import CoreData

struct LentItemListView: View {

    @StateObject private var viewModel: LentItemViewModel
    @State private var showingAddItem = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""

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
        .overlay(
            VStack {
                Spacer()
                if showSnackbar {
                    SnackbarView(message: snackbarMessage)
                        .padding(.bottom, 32)
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSnackbar)
        )
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
                    rowView(for: item)
                }
            } header: {
                itemCountHeader
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    // MARK: - Snackbar

    private func triggerSnackbar(_ message: String) {
        snackbarMessage = message
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSnackbar = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSnackbar = false
            }
        }
    }

    // MARK: - Row helpers

    @ViewBuilder
    private func rowView(for item: LentItem) -> some View {
        if #available(iOS 15, *) {
            LentItemRowView(item: item)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation { viewModel.delete(item) }
                    } label: {
                        Label("Apagar", systemImage: "trash.fill")
                    }

                    Button {
                        withAnimation { viewModel.markAsReturned(item) }
                        triggerSnackbar("🥳 Devolvido! Finalmente")
                    } label: {
                        Label("Devolvido", systemImage: "checkmark.circle.fill")
                    }
                    .tint(.blue)
                }
                .contextMenu { contextMenuContent(for: item) }
        } else {
            LentItemRowView(item: item)
                .contextMenu { contextMenuContent(for: item) }
        }
    }

    @ViewBuilder
    private func contextMenuContent(for item: LentItem) -> some View {
        Button(action: {
            withAnimation { viewModel.markAsReturned(item) }
        }) {
            Label("Marcar como Devolvido", systemImage: "checkmark.circle.fill")
        }

        Button(action: {
            WhatsAppHelper.sendItemReminder(to: item.wrappedPersonName, itemName: item.wrappedItemName)
        }) {
            Label("Cobrar via WhatsApp", systemImage: "message.fill")
        }

        Button(action: {
            withAnimation { viewModel.delete(item) }
        }) {
            Label("Apagar", systemImage: "trash.fill")
        }
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
