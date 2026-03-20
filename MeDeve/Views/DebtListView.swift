import SwiftUI
import CoreData

struct DebtListView: View {

    @StateObject private var viewModel: IOUViewModel
    @State private var showingAddDebt = false
    @State private var showSnackbar = false
    @State private var snackbarMessage = ""

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
                    rowView(for: iou)
                }
            } header: {
                totalHeader
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
    private func rowView(for iou: IOU) -> some View {
        if #available(iOS 15, *) {
            DebtRowView(iou: iou)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation { viewModel.delete(iou) }
                    } label: {
                        Label("Apagar", systemImage: "trash.fill")
                    }

                    Button {
                        withAnimation { viewModel.markAsPaid(iou) }
                        triggerSnackbar("🎉 Pago! Finalmente")
                    } label: {
                        Label("Pago", systemImage: "checkmark.circle.fill")
                    }
                    .tint(.blue)
                }
                .contextMenu { contextMenuContent(for: iou) }
        } else {
            DebtRowView(iou: iou)
                .contextMenu { contextMenuContent(for: iou) }
        }
    }

    @ViewBuilder
    private func contextMenuContent(for iou: IOU) -> some View {
        Button(action: {
            withAnimation { viewModel.markAsPaid(iou) }
        }) {
            Label("Marcar como Pago", systemImage: "checkmark.circle.fill")
        }

        Button(action: {
            WhatsAppHelper.sendReminder(to: iou.wrappedPersonName, amount: iou.amount)
        }) {
            Label("Cobrar via WhatsApp", systemImage: "message.fill")
        }

        Button(action: {
            withAnimation { viewModel.delete(iou) }
        }) {
            Label("Apagar", systemImage: "trash.fill")
        }
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
