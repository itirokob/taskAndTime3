

import Intents

class IntentHandler: INExtension, INStartWorkoutIntentHandling, INEndWorkoutIntentHandling {
    
    func handle(startWorkout intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        
        let userActivity: NSUserActivity? = nil
        guard (intent.workoutName?.spokenPhrase) != nil else {
            completion(INStartWorkoutIntentResponse(code: .failureNoMatchingWorkout, userActivity: userActivity))
            return
        }
        
        completion(INStartWorkoutIntentResponse(code: .continueInApp, userActivity: userActivity))
    }
    
    func handle(endWorkout intent: INEndWorkoutIntent, completion: @escaping (INEndWorkoutIntentResponse) -> Void) {
        
    }
}
