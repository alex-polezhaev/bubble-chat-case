import GRDB
import SwiftUI

// DebugMenu: Main menu for displaying all tables
struct ModelListView: View {
    // Array of table names
    let allTables: [String] = [
        "users",
        "contacts",
        "chats",
        "chat_members",
        "posts",
        "media",
        "layers",
        "comments",
        "reactions",
        "delivery_tracks",
        "user_activities",
        "queue_requests",
    ]

    @State private var selectedTable: String? = "users"
    @State private var isSheetPresented: Bool = false

    var body: some View {
        NavigationView {
            List(allTables, id: \.self) { table in
                Button(action: {
                    isSheetPresented = true
                    selectedTable = table
                }) {
                    Text(table)
                }
            }
            .navigationTitle("Debug Menu")
            .sheet(isPresented: $isSheetPresented) {
                if let table = selectedTable {
                    TableDataView(tableName: table)
                }
            }
        }
    }
}

// TableDataView: Screen for displaying the data of the selected table
struct TableDataView: View {
    let tableName: String
    @State private var data: [[String: Any]] = []
    @State private var itemCount: Int = 0

    var body: some View {
        VStack {
            HStack {
                Text("\(itemCount) items in \(tableName)")
                    .font(.headline)
                Spacer()
            }
            .padding()

            if data.isEmpty {
                Text("No data available for \(tableName)")
                    .padding()
            } else {
                List {
                    ForEach(data.indices, id: \.self) { index in
                        Section(header: Text("Item \(index + 1)")) {
                            ForEach(data[index].sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                HStack {
                                    Text(key).fontWeight(.bold)
                                    Spacer()
                                    Text("\(value)").multilineTextAlignment(.trailing)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(tableName)
        .onAppear(perform: fetchData)
    }

    private func fetchData() {
        do {
            let dbPool = AppDatabase.shared.dbPool
            try dbPool.read { db in
                var sql = "SELECT * FROM \(tableName)"
                if tableName == "contacts" {
                    sql = "SELECT * FROM \(tableName) WHERE userId IS NOT NULL"
                }
                data = try fetchRows(from: db, sql: sql)
                itemCount = data.count
            }
        } catch {
            print("Error fetching data for \(tableName): \(error)")
        }
    }

    private func fetchRows(from db: Database, sql: String) throws -> [[String: Any]] {
        let rows = try Row.fetchAll(db, sql: sql)
        return rows.map { row in
            var result: [String: Any] = [:]
            for columnName in row.columnNames {
                if let data = row[columnName] as? Data, data.count == 16 {
                    // Convert 16 bytes into a UUID
                    let uuid = UUID(uuid: (
                        data[0], data[1], data[2], data[3],
                        data[4], data[5], data[6], data[7],
                        data[8], data[9], data[10], data[11],
                        data[12], data[13], data[14], data[15]
                    ))
                    result[columnName] = uuid.uuidString
                } else {
                    result[columnName] = row[columnName] // Keep the remaining values unchanged
                }
            }
            return result
        }
    }
}
