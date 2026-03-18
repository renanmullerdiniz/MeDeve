import SwiftUI

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            DebtListView(context: viewContext)
                .tabItem {
                    Label("Dívidas", systemImage: "banknote")
                }

            LentItemListView(context: viewContext)
                .tabItem {
                    Label("Empréstimos", systemImage: "tshirt")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
    }
}
