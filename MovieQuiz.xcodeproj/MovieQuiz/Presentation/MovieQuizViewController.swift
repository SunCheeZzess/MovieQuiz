import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
//        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileName = "inception.json"
//        documentsURL.appendPathComponent(fileName)
//        let jsonString = try? String(contentsOf: documentsURL)
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()

    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.show(quizStep: viewModel)
            }
    }
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    // MARK: - IB Outlets
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    
    private let questionAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let alertPresenter: AlertPresenter? = nil
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    

    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) /\(questionAmount)")
        
        return questionStep
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor  = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
    }
    
    private func show(quizStep: QuizStepViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = quizStep.image
            self?.textLabel.text = quizStep.question
            self?.questionTitleLabel.text = quizStep.questionNumber
        }
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }

    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionAmount - 1 {
            let text = correctAnswers == questionAmount ?
            "Поздравляем ваш результат 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ешё раз!"
            let model = AlertModel(title: "Игра окончена!", text: text, buttonText: "Сыграть ещё раз", completion: {[weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
            alertPresenter?.show(model: model)
        } else {
            currentQuestionIndex += 1
            if let questionFactory = questionFactory {
                questionFactory.requestNextQuestion()
            }
        }
    }
    
}
    



