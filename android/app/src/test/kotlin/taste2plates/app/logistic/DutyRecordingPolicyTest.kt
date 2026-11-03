package taste2plates.app.logistic

import org.junit.Assert.*
import org.junit.Test

class DutyRecordingPolicyTest {
    @Test fun savesFirstPointAndThirtyMetreTurnsWithoutWaitingThirtySeconds() {
        assertTrue(DutyRecordingPolicy.shouldSave(false, 0f, 0))
        assertFalse(DutyRecordingPolicy.shouldSave(true, 29.9f, 10_000))
        assertTrue(DutyRecordingPolicy.shouldSave(true, 30f, 5_000))
        assertTrue(DutyRecordingPolicy.shouldSave(true, 40f, 10_000))
    }

    @Test fun stationaryFiveMinutesProducesTenNewSavedPoints() {
        var lastSaved = 0L
        var count = 0
        for (now in 10_000L..300_000L step 10_000) {
            if (DutyRecordingPolicy.shouldSave(true, 0f, now - lastSaved)) {
                count++
                lastSaved = now
            }
        }
        assertEquals(10, count)
        assertEquals(300_000L, lastSaved)
    }
}
