
import UIKit

protocol RoundCoordinatorDelegate: AnyObject {
    func didLoadFilmsData()
    func didFailLoadFilmData(with error: Error)
    
    func didReceiveNewQuestion(_ question: QuizQuestion?)
    func roundDidEnd(_ round: RoundCoordinator, withResult gameRecord: GameRecord)
}
