
import Foundation

protocol DataLoadingDelegate {
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func loadData()
}
