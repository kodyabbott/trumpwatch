import Foundation

@MainActor
final class PresidencyMonitor: ObservableObject {
    static let shared = PresidencyMonitor()

    @Published private(set) var isStillPresident: Bool
    @Published private(set) var lastChecked: Date?
    @Published private(set) var departureDate: Date?

    private let trumpID = "Q22686"
    private let store = UserDefaults.standard

    /// Normal end of second term: January 20, 2029 at noon ET.
    /// The app only triggers if he leaves before this date.
    private let termEnd: Date = {
        var c = DateComponents()
        c.year = 2029
        c.month = 1
        c.day = 20
        c.hour = 12
        c.timeZone = TimeZone(identifier: "America/New_York")
        return Calendar.current.date(from: c)!
    }()

    private init() {
        let departed = store.bool(forKey: "departed")
        self.isStillPresident = !departed
        self.departureDate = store.object(forKey: "departureDate") as? Date
    }

    @Published private(set) var isChecking = false

    func check() {
        guard !isChecking else { return }
        isChecking = true
        Task {
            async let _ = performCheck()
            try? await Task.sleep(for: .seconds(2))
            isChecking = false
        }
    }

    func performCheck() async {
        guard isStillPresident, Date() < termEnd else { return }

        do {
            let stillInOffice = try await fetchCurrentPresident()
            lastChecked = Date()

            if !stillInOffice {
                isStillPresident = false
                departureDate = Date()
                store.set(true, forKey: "departed")
                store.set(Date(), forKey: "departureDate")
                await NotificationManager.shared.sendAlert()
            }
        } catch {
            lastChecked = Date()
        }
    }

    /// Queries Wikidata for the current head of government of the United States (Q30).
    /// Returns true if the current head of government is Donald Trump (Q22686).
    private func fetchCurrentPresident() async throws -> Bool {
        let sparql = "SELECT ?p WHERE { wd:Q30 wdt:P6 ?p . }"

        var components = URLComponents(string: "https://query.wikidata.org/sparql")!
        components.queryItems = [
            URLQueryItem(name: "query", value: sparql),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components.url else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.setValue("TrumpWatch/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        req.setValue("application/sparql-results+json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 30

        let (data, _) = try await URLSession.shared.data(for: req)
        let result = try JSONDecoder().decode(SPARQLResponse.self, from: data)

        return result.results.bindings.contains { $0.p.value.hasSuffix("/\(trumpID)") }
    }
}

// MARK: - Wikidata SPARQL response

private struct SPARQLResponse: Codable {
    let results: Results
    struct Results: Codable { let bindings: [Binding] }
    struct Binding: Codable { let p: Value }
    struct Value: Codable { let value: String }
}
