import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String // Binding for the search text

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search your friends", text: $searchText) // Text input field
                .autocapitalization(.none) // Disable automatic capitalization
                .disableAutocorrection(true) // Disable autocorrection
        }
        .foregroundStyle(.gray)
        .font(.system(size: 16, weight: .regular, design: .rounded))
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            Capsule().fill(.black.opacity(0.1))
        )
    }
}
