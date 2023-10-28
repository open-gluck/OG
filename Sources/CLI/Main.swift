import Foundation
import OG

let token = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_TOKEN"]!
let hostname = ProcessInfo.processInfo.environment["TEST_OPENGLUCK_HOSTNAME"]!

let ogClient = OpenGlückClient(hostname: hostname, token: token, target: "cli")

let records = try await ogClient.getLastData()
print(records)

let records24h = try await ogClient.findGlucoseRecords(from: Date(timeIntervalSinceNow: -86400), until: Date())
print("Records last 24h:")
print(records24h)

let hasRealTime = try await ogClient.getHasRealTime()
print("Has real time: \(String(describing: hasRealTime))")

let (currentEpisode, currentEpisodeTimestamp) = try await ogClient.getCurrentEpisode()
print("Current episode: \(String(describing: currentEpisode)), at \(String(describing: currentEpisodeTimestamp))")

let currentData = try await ogClient.getCurrentData()
print("Current data: \(currentData)")
