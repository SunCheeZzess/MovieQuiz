import UIKit

class Round: QuestionFactoryDelegate {
    
    //MARK: - Properties
    weak var delegate: RoundDelegate?
    private let questionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCount: Int = 0
    private var questionCount = 10
    private var gameRecord: GameRecord?
    
    //MARK: - Initialization
    init() {
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        if let question = question {
            self.currentQuestion = question
            delegate?.didReceiveNewQuestion(question)
        } else if isRoundComplete() {
            finishRound()
        }
    }
    
    // MARK: - Methods
    func requestNextQuestion() {
        questionFactory.requestNextQuestion()
    }
    
    func getCurrentQuestion() -> QuizQuestion? {
        if currentQuestionIndex < questionCount {
            return currentQuestion
        }
        return nil
    }
    
    func getNumberCurrentQuestion() -> Int {
        currentQuestionIndex
    }
    
    func getCountQuestions() -> Int {
        questionCount
    }
    
    func getCorrectCountAnswer() -> Int {
        correctAnswersCount
    }
    
    func checkAnswer(checkTap: Bool) -> Bool {
        guard let currentQuestion = getCurrentQuestion() else {
            return false
        }
        
        let isCorrect = currentQuestion.correctAnswer == checkTap
        if isCorrect {
            correctAnswersCount += 1
        }
        
        currentQuestionIndex += 1
        
        if isRoundComplete() {
            finishRound()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.requestNextQuestion()
            }
        }
        
        return isCorrect
    }
    
    func getGameRecord() -> GameRecord? {
        guard let gameRecord = gameRecord else {
            return nil
        }
        return gameRecord
    }
    
    // MARK: - Private Methods
    private func isRoundComplete() -> Bool {
        return currentQuestionIndex >= questionCount
    }
    
    private func finishRound() {
        let newGameRecord = GameRecord(correct: correctAnswersCount, total: questionCount, date: Date())
        gameRecord = newGameRecord
        StatisticServiceImplementation().store(currentRound: self)
        delegate?.roundDidEnd(self, withResult: newGameRecord)
    }
}
