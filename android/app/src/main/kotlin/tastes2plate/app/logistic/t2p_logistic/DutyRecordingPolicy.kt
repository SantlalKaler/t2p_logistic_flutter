package taste2plates.app.logistic

/** The distance threshold gates SAVING only; GPS itself has a zero distance filter. */
object DutyRecordingPolicy {
    fun shouldSave(hasPrevious: Boolean, distanceMetres: Float, elapsedMillis: Long): Boolean =
        !hasPrevious || distanceMetres >= 30f || elapsedMillis >= 30_000
}
