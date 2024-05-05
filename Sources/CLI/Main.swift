import Foundation
import OG

let token = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_TOKEN"]!
let hostname = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_HOSTNAME"]!

let ogClient = OpenGluckClient(hostname: hostname, token: token, target: "cli")

let records = try await ogClient.getLastData()
if let records {
    print(records)
} else {
    print("No records")
}

let records24h = try await ogClient.findGlucoseRecords(from: Date(timeIntervalSinceNow: -86400), until: Date())
print("Records last 24h:")
print(records24h)

let hasRealTime = try await ogClient.getHasRealTime()
print("Has real time: \(String(describing: hasRealTime))")

let (currentEpisode, currentEpisodeTimestamp) = try await ogClient.getCurrentEpisode()
print("Current episode: \(String(describing: currentEpisode)), at \(String(describing: currentEpisodeTimestamp))")

let currentData = try await ogClient.getCurrentData()
print("Current data: \(String(describing: currentData))")

let hbA1cToday = try await ogClient.getHbA1cToday()
print("HbA1c today: \(String(describing: hbA1cToday))")

let hbA1cLast24Hours = try await ogClient.getHbA1cLast24Hours()
print("HbA1c last 24 hours: \(String(describing: hbA1cLast24Hours))")

let hbA1cYesterday = try await ogClient.getHbA1cYesterday()
print("HbA1c yesterday: \(String(describing: hbA1cYesterday))")

let hbA1cLast7Days = try await ogClient.getHbA1cLast7Days()
print("HbA1c last 7 days: \(String(describing: hbA1cLast7Days))")

let hbA1cLast30Days = try await ogClient.getHbA1cLast30Days()
print("HbA1c last 30 days: \(String(describing: hbA1cLast30Days))")

let hbA1cLast90Days = try await ogClient.getHbA1cLast90Days()
print("HbA1c last 90 days: \(String(describing: hbA1cLast90Days))")
