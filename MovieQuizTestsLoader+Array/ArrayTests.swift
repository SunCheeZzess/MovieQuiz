import XCTest
 @testable import MovieQuiz

 class ArrayTests:XCTestCase {
     func testGetValueInRange() throws {

         let array = [1, 1, 2, 3, 5]

         let value = array[safe: 0]

         XCTAssertNotNil(value)
         XCTAssertEqual(value, 1)
     }

     func testGetValoueOutOfRange() throws {

         let array = [1, 2, 3, 4, 5]

         let value = array[safe: 20]

         XCTAssertNil(value)
     }
 }
