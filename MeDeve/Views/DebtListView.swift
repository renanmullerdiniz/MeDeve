import SwiftUI
import CoreData

struct DebtListView: View {

    @StateObject private var viewModel: IOUViewModel
    @State private var showingAddDebt = false

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: IOUViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                if viewModel.ious.isEmpty {
                    emptyStateView
                } else {
                    debtList
                }
            }
            .navigationTitle("MeDeve")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddDebt = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Adicionar dívida")
                }
            }
            .sheet(isPresented: $showingAddDebt, onDismiss: viewModel.fetchIOUs) {
                AddDebtView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundColor(.green)

            Text("Você não tem cobranças pendentes!")
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

    private var debtList: some View {
        List {
            Section {
                ForEach(viewModel.ious, id: \.id) { iou in
                    DebtRowView(iou: iou, onPaid: {
                        withAnimation { viewModel.markAsPaid(iou) }
                    })
                        .contextMenu {
                            Button(action: {
                                withAnimation { viewModel.markAsPaid(iou) }
                            }) {
                                Label("Marcar como Pago", systemImage: "checkmark.circle.fill")
                            }

                            Button(action: {
                                WhatsAppHelper.sendReminder(
                                    to: iou.wrappedPersonName,
                                    amount: iou.amount
                                )
                            }) {
                                Label("Cobrar via WhatsApp", systemImage: "message.fill")
                            }

                            Button(action: {
                                withAnimation { viewModel.delete(iou) }
                            }) {
                                Label("Apagar", systemImage: "trash.fill")
                            }
                        }
                }
                .onDelete { offsets in
                    withAnimation { viewModel.delete(at: offsets) }
                }
            } header: {
                totalHeader
            }
        }
        .listStyle(InsetGroupedListStyle())
    }

    private var totalHeader: some View {
        let total = viewModel.ious.reduce(0) { $0 + $1.amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale      = Locale(identifier: "pt_BR")
        let formatted = formatter.string(from: NSNumber(value: total)) ?? "R$ \(total)"

        return HStack {
            Text("\(viewModel.ious.count) dívida\(viewModel.ious.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text("Total: \(formatted)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .textCase(nil)
    }
}

struct DebtListView_Previews: PreviewProvider {
    static var previews: some View {
        DebtListView(context: PersistenceController.preview.container.viewContext)
    }
}
