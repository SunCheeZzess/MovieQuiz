import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, RoundCoordinatorDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    

    
    // MARK: - Private Properties
    private let alertPresenter = AlertPresenter()
    private var statisticService =  StatisticServiceImplementation()
    private lazy var roundCoordinator = RoundCoordinator(
        questionFactory: QuestionFactory(moviesLoader:
        MoviesLoader()),
        statisticService: statisticService
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewRound()
        setupImageView()
        showLoadingIndicator()
        alertPresenter.delegate = self
    }
    
    // MARK: - Setup Methods
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
    
    private func setAnswerButtonsEnabled(_ enabled: Bool) {
        noButton.isEnabled = enabled
        yesButton.isEnabled = enabled
    }
    
    // MARK: - Quiz Logic
    private func startNewRound() {
        setAnswerButtonsEnabled(true)
        setAnswerButtonsEnabled(false)
        roundCoordinator.delegate = self
        roundCoordinator.correctAnswersCount = 0
        roundCoordinator.currentQuestionIndex = 0
        roundCoordinator.loadFilmsData()
    }
    
    // MARK: - RoundDelegate
    func didLoadFilmsData() {
        hideLoadingIndicator()
        roundCoordinator.requestNextQuestion()
    }
    
    func didFailLoadFilmData(with error: Error) {
        hideLoadingIndicator()
        showError(message: "Не удалось загрузить данные")
    }
    
    func didReceiveNewQuestion(_ question: QuizQuestion?) {
        guard let question = question else { return }
        
        setAnswerButtonsEnabled(true)
        showQuestion(quiz: convert(model: question))
    }
    
    func roundDidEnd(_ round: RoundCoordinator, withResult gameRecord: GameRecord) {
        statisticService = StatisticServiceImplementation()
        showQuizResults()
    }
    

    
    // MARK: - AlertPresenterDelegate
    func alertDidDismiss() {
        startNewRound()
    }
    
    // MARK: - UI Updates
    func didReceiveNextQuestion(question: QuizQuestion?) {
        textLabel.text = question?.text
        if let imageData = question?.image {
            imageView.image = UIImage(data: imageData)
        } else {
            imageView.image = nil
        }
        counterLabel.text = "\(roundCoordinator.getNumberCurrentQuestion()) / \(roundCoordinator.getCountQuestions())"
    }
    
    private func showQuizResults() {
        showStatistics(
            model: statisticService.bestGame,
            gamesCount: statisticService.gamesCount,
            totalAccuracy: statisticService.totalAccuracy
            )
    }
    
    
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func showQuestionAnswerResult(isCorrect: Bool) {
        self.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    
    // MARK: - IBActions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        let isCorrect = roundCoordinator.checkAnswer(checkTap: false)
        showQuestionAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        let isCorrect = roundCoordinator.checkAnswer(checkTap: true)
        showQuestionAnswerResult(isCorrect: isCorrect)
    }
    
    // MARK: - Model Conversion
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = roundCoordinator.getNumberCurrentQuestion()
        let totalQuestions = roundCoordinator.getCountQuestions()
        let displayNumber = questionNumber + 1
        
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(displayNumber) / \(totalQuestions)"
        )
    }
    
    // MARK: - Show Alerts
    private func showError(message: String) {
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Ок"
        )
        
        self.roundCoordinator.correctAnswersCount = 0
        self.roundCoordinator.currentQuestionIndex = 0
        
        alertPresenter.present(alertModel: model, on: self)
    }
        

    private func showStatistics(model: GameRecord, gamesCount: Int, totalAccuracy: String) {
        let totalQuestions = roundCoordinator.getCountQuestions()
        let correctAnswers = roundCoordinator.getCorrectCountAnswer()
        
        let recordDate = model.date
        let recordTotal = model.total
        let recordCorrect = model.correct
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: """
            Ваш результат: \(correctAnswers) / \(totalQuestions)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(recordCorrect) / \(recordTotal) (\(recordDate.dateTimeString))
            Средняя точность: \(totalAccuracy)%
            """,
            buttonText: "Сыграть ещё раз"
        )
        alertPresenter.present(alertModel: alertModel, on: self)
    }
    
    // MARK: AlertNetworkError
    
    private func showNetworkError(message: String) {
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Ок"
        )
        
        self.roundCoordinator.correctAnswersCount = 0
        self.roundCoordinator.currentQuestionIndex = 0
        
        alertPresenter.present(alertModel: model, on: self)
    }
    
    // MARK: Indicator Methods
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    // MARK: Service Methods
    fileprivate func printAllUserDefaults() {
        let userDefaults = UserDefaults.standard
        print("All UserDefaults:")
        for (key, value) in userDefaults.dictionaryRepresentation() {
            print("\(key) = \(value)")
        }
    }
    
        func remove() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
