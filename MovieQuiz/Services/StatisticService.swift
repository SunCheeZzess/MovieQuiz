
import UIKit

protocol StatisticService {
    func store(currentRound: RoundCoordinator)
    var totalAccuracy: String { get }
    var gamesCount : Int { get }
    var bestGame: GameRecord { get }
}
