
import UIKit

protocol RoundDelegate: AnyObject, DataLoadingDelegate {
    func didReceiveNewQuestion(_ question: QuizQuestion?)
    func roundDidEnd(_ round: RoundCoordinator, withResult gameRecord: GameRecord)
}
