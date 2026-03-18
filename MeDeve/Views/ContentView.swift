import SwiftUI

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        DebtListView(context: viewContext)
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
