import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, RoundDelegate, QuestionFactoryDelegate {
    func loadData() {
        <#code#>
    }
    


    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    

    
    // MARK: - Private Properties
    private let alertPresenter = AlertPresenter()
    private var currentRound: Round?
    private var statisticService: StatisticService?
    private let moviesLoader = MoviesLoader()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        alertPresenter.delegate = self
        startNewRound()
        showLoadingIndicator()
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
        currentRound = Round(moviesLoader: moviesLoader, delegate: self)
        currentRound?.delegate = self
        currentRound?.requestNextQuestion()
    }
    
    // MARK: - RoundDelegate
    func didReceiveNewQuestion(_ question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        showQuestion(quiz: convert(model: question))
        
        setAnswerButtonsEnabled(true)
    }
    
    func roundDidEnd(_ round: Round, withResult gameRecord: GameRecord) {
        statisticService = StatisticServiceImplementation()
        showQuizResults()
    }
    

    
    // MARK: - AlertPresenterDelegate
    func alertDidDismiss() {
        startNewRound()
    }
    
    //MARK: Checking NetworkErrors
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        currentRound?.requestNextQuestion()
    }
    
    // MARK: - UI Updates
    func didReceiveNextQuestion(question: QuizQuestion?) {
        textLabel.text = question?.text
        if let imageData = question?.image {
            imageView.image = UIImage(data: imageData)
        } else {
            imageView.image = nil
        }
        counterLabel.text = "\(currentRound?.getNumberCurrentQuestion() ?? 0) / \(currentRound?.getCountQuestions() ?? 0)"
    }
    private func showQuizResults() {
        let model1 = statisticService
        let alertModel1 = convert1(model: model1)
        alertPresenter.present(alertModel: alertModel1, on: self)
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
        let isCorrect = currentRound?.checkAnswer(checkTap: false) ?? false
        showQuestionAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        let isCorrect = currentRound?.checkAnswer(checkTap: true) ?? false
        showQuestionAnswerResult(isCorrect: isCorrect)
    }
    
    // MARK: - Model Conversion
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = currentRound?.getNumberCurrentQuestion() ?? 0
        let totalQuestions = currentRound?.getCountQuestions() ?? 0
        let displayNumber = questionNumber + 1
        
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(displayNumber) / \(totalQuestions)"
        )
    }
    
    private func convert1(model: StatisticService?) -> AlertModel {
        guard let bestGame = model?.bestGame else {
            return AlertModel(title: "Ошибка", message: "Данные не доступны!", buttonText: "ОК")
        }
        
        let gamesCount = model?.gamesCount ?? 0
        let gamesAccuracy = model?.totalAccuracy ?? "0.0"
        
        let correctAnswers = currentRound?.getCorrectCountAnswer() ?? 0
        let totalQuestions = currentRound?.getCountQuestions() ?? 0
        
        let recordCorrect = bestGame.correct
        let recordTotal = bestGame.total
        let recordDate = bestGame.date
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: """
            Ваш результат: \(correctAnswers) / \(totalQuestions)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(recordCorrect) / \(recordTotal) (\(recordDate.dateTimeString))
            Средняя точность: \(gamesAccuracy)%
            """,
            buttonText: "Сыграть ещё раз"
        )
        
        return alertModel
    }
    
    // MARK: AlertNetworkError
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать ещё раз")
        
        self.currentRound?.currentQuestionIndex = 0
        self.currentRound?.correctAnswersCount = 0
        self.currentRound?.requestNextQuestion()
        
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
    
    fileprivate func remove() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
