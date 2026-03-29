import XCTest
@testable import AuriTails

final class AuriTailsTests: XCTestCase {
    func testClockTimeShiftWrapsAcrossMidnight() {
        let shifted = ClockTime(hour: 23, minute: 45).shifted(by: 30)
        XCTAssertEqual(shifted, ClockTime(hour: 0, minute: 15))
    }

    func testRescheduleRoutineMovesItemToNewDay() {
        let viewModel = AppViewModel.preview()
        let routineID = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000001")!

        viewModel.rescheduleRoutine(routineID, to: .friday)

        XCTAssertTrue(viewModel.routines.contains(where: { $0.id == routineID && $0.day == .friday }))
        XCTAssertEqual(viewModel.selectedDay, .friday)
    }

    func testInsightEngineReturnsGuidanceForPreviewData() {
        let viewModel = AppViewModel.preview()
        let insights = PetInsightEngine().generateInsights(
            snapshots: viewModel.behaviorSnapshots,
            routines: viewModel.routines,
            foodPreferences: viewModel.foodPreferences,
            pet: viewModel.pet
        )

        XCTAssertFalse(insights.isEmpty)
        XCTAssertTrue(insights.contains(where: { $0.title.localizedCaseInsensitiveContains("Move one energetic ritual earlier") }))
    }
}
