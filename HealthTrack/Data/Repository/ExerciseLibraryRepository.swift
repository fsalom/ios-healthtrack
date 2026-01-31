//
//  ExerciseLibraryRepository.swift
//  HealthTrack
//

import Foundation

final class ExerciseLibraryRepository: ExerciseLibraryRepositoryProtocol {

    // MARK: - Properties

    private let userDefaults: UserDefaults
    private let customTemplatesKey = "custom_exercise_templates_v1"
    private let historyKey = "exercise_history_v1"

    // MARK: - Built-in Exercises

    private let builtInExercises: [ExerciseTemplateModel] = [
        // MARK: Pecho
        ExerciseTemplateModel(name: "Press banca", category: .chest, muscleGroups: [.ppiectoralMajor, .deltoids, .triceps]),
        ExerciseTemplateModel(name: "Press inclinado", category: .chest, muscleGroups: [.ppiectoralMajor, .deltoids]),
        ExerciseTemplateModel(name: "Press declinado", category: .chest, muscleGroups: [.ppiectoralMajor, .triceps]),
        ExerciseTemplateModel(name: "Aperturas con mancuernas", category: .chest, muscleGroups: [.ppiectoralMajor]),
        ExerciseTemplateModel(name: "Aperturas en polea", category: .chest, muscleGroups: [.ppiectoralMajor]),
        ExerciseTemplateModel(name: "Fondos en paralelas", category: .chest, muscleGroups: [.ppiectoralMajor, .triceps]),
        ExerciseTemplateModel(name: "Pull over", category: .chest, muscleGroups: [.ppiectoralMajor, .latissimusDorsi]),

        // MARK: Espalda
        ExerciseTemplateModel(name: "Dominadas", category: .back, muscleGroups: [.latissimusDorsi, .biceps]),
        ExerciseTemplateModel(name: "Dominadas agarre neutro", category: .back, muscleGroups: [.latissimusDorsi, .biceps]),
        ExerciseTemplateModel(name: "Jalon al pecho", category: .back, muscleGroups: [.latissimusDorsi, .biceps]),
        ExerciseTemplateModel(name: "Jalon agarre cerrado", category: .back, muscleGroups: [.latissimusDorsi, .biceps]),
        ExerciseTemplateModel(name: "Remo con barra", category: .back, muscleGroups: [.latissimusDorsi, .trapezius, .biceps]),
        ExerciseTemplateModel(name: "Remo con mancuerna", category: .back, muscleGroups: [.latissimusDorsi, .biceps]),
        ExerciseTemplateModel(name: "Remo en polea baja", category: .back, muscleGroups: [.latissimusDorsi, .trapezius]),
        ExerciseTemplateModel(name: "Peso muerto", category: .back, muscleGroups: [.lowerBack, .hamstrings, .glutes, .trapezius]),
        ExerciseTemplateModel(name: "Peso muerto rumano", category: .back, muscleGroups: [.lowerBack, .hamstrings, .glutes]),
        ExerciseTemplateModel(name: "Hiperextensiones", category: .back, muscleGroups: [.lowerBack, .glutes]),

        // MARK: Piernas
        ExerciseTemplateModel(name: "Sentadilla", category: .legs, muscleGroups: [.quadriceps, .glutes, .hamstrings]),
        ExerciseTemplateModel(name: "Sentadilla frontal", category: .legs, muscleGroups: [.quadriceps, .glutes]),
        ExerciseTemplateModel(name: "Sentadilla bulgara", category: .legs, muscleGroups: [.quadriceps, .glutes]),
        ExerciseTemplateModel(name: "Prensa", category: .legs, muscleGroups: [.quadriceps, .glutes]),
        ExerciseTemplateModel(name: "Hack squat", category: .legs, muscleGroups: [.quadriceps, .glutes]),
        ExerciseTemplateModel(name: "Zancadas", category: .legs, muscleGroups: [.quadriceps, .glutes]),
        ExerciseTemplateModel(name: "Extension de cuadriceps", category: .legs, muscleGroups: [.quadriceps]),
        ExerciseTemplateModel(name: "Curl femoral", category: .legs, muscleGroups: [.hamstrings]),
        ExerciseTemplateModel(name: "Curl femoral sentado", category: .legs, muscleGroups: [.hamstrings]),
        ExerciseTemplateModel(name: "Hip thrust", category: .legs, muscleGroups: [.glutes, .hamstrings]),
        ExerciseTemplateModel(name: "Elevacion de gemelos", category: .legs, muscleGroups: [.calves]),
        ExerciseTemplateModel(name: "Elevacion de gemelos sentado", category: .legs, muscleGroups: [.calves]),
        ExerciseTemplateModel(name: "Aductores", category: .legs, muscleGroups: [.glutes]),
        ExerciseTemplateModel(name: "Abductores", category: .legs, muscleGroups: [.glutes]),

        // MARK: Hombros
        ExerciseTemplateModel(name: "Press militar", category: .shoulders, muscleGroups: [.deltoids, .triceps]),
        ExerciseTemplateModel(name: "Press Arnold", category: .shoulders, muscleGroups: [.deltoids, .triceps]),
        ExerciseTemplateModel(name: "Press con mancuernas", category: .shoulders, muscleGroups: [.deltoids, .triceps]),
        ExerciseTemplateModel(name: "Elevaciones laterales", category: .shoulders, muscleGroups: [.deltoids]),
        ExerciseTemplateModel(name: "Elevaciones frontales", category: .shoulders, muscleGroups: [.deltoids]),
        ExerciseTemplateModel(name: "Pajaros", category: .shoulders, muscleGroups: [.deltoids, .trapezius]),
        ExerciseTemplateModel(name: "Face pull", category: .shoulders, muscleGroups: [.deltoids, .trapezius]),
        ExerciseTemplateModel(name: "Encogimientos", category: .shoulders, muscleGroups: [.trapezius]),

        // MARK: Brazos
        ExerciseTemplateModel(name: "Curl con barra", category: .arms, muscleGroups: [.biceps]),
        ExerciseTemplateModel(name: "Curl con mancuernas", category: .arms, muscleGroups: [.biceps]),
        ExerciseTemplateModel(name: "Curl martillo", category: .arms, muscleGroups: [.biceps, .forearms]),
        ExerciseTemplateModel(name: "Curl concentrado", category: .arms, muscleGroups: [.biceps]),
        ExerciseTemplateModel(name: "Curl en polea", category: .arms, muscleGroups: [.biceps]),
        ExerciseTemplateModel(name: "Curl predicador", category: .arms, muscleGroups: [.biceps]),
        ExerciseTemplateModel(name: "Extension de triceps en polea", category: .arms, muscleGroups: [.triceps]),
        ExerciseTemplateModel(name: "Press frances", category: .arms, muscleGroups: [.triceps]),
        ExerciseTemplateModel(name: "Fondos en banco", category: .arms, muscleGroups: [.triceps]),
        ExerciseTemplateModel(name: "Patada de triceps", category: .arms, muscleGroups: [.triceps]),
        ExerciseTemplateModel(name: "Extension de triceps sobre cabeza", category: .arms, muscleGroups: [.triceps]),
        ExerciseTemplateModel(name: "Curl de muneca", category: .arms, muscleGroups: [.forearms]),

        // MARK: Core
        ExerciseTemplateModel(name: "Plancha", category: .core, muscleGroups: [.abs, .obliques]),
        ExerciseTemplateModel(name: "Plancha lateral", category: .core, muscleGroups: [.obliques]),
        ExerciseTemplateModel(name: "Crunch", category: .core, muscleGroups: [.abs]),
        ExerciseTemplateModel(name: "Crunch en polea", category: .core, muscleGroups: [.abs]),
        ExerciseTemplateModel(name: "Elevacion de piernas", category: .core, muscleGroups: [.abs]),
        ExerciseTemplateModel(name: "Elevacion de piernas colgado", category: .core, muscleGroups: [.abs]),
        ExerciseTemplateModel(name: "Russian twist", category: .core, muscleGroups: [.obliques]),
        ExerciseTemplateModel(name: "Ab wheel", category: .core, muscleGroups: [.abs]),
        ExerciseTemplateModel(name: "Dead bug", category: .core, muscleGroups: [.abs]),
        ExerciseTemplateModel(name: "Bird dog", category: .core, muscleGroups: [.abs, .lowerBack]),

        // MARK: Cardio
        ExerciseTemplateModel(name: "Burpees", category: .cardio, muscleGroups: [.quadriceps, .ppiectoralMajor]),
        ExerciseTemplateModel(name: "Mountain climbers", category: .cardio, muscleGroups: [.abs, .quadriceps]),
        ExerciseTemplateModel(name: "Jumping jacks", category: .cardio, muscleGroups: [.quadriceps, .calves]),
        ExerciseTemplateModel(name: "Box jumps", category: .cardio, muscleGroups: [.quadriceps, .glutes]),
        ExerciseTemplateModel(name: "Battle ropes", category: .cardio, muscleGroups: [.deltoids, .abs])
    ]

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Templates

    func getAllTemplates() async throws -> [ExerciseTemplateModel] {
        let customTemplates = try await getCustomTemplates()
        return builtInExercises + customTemplates
    }

    func getTemplates(for category: ExerciseCategory) async throws -> [ExerciseTemplateModel] {
        let all = try await getAllTemplates()
        return all.filter { $0.category == category }
    }

    func searchTemplates(query: String) async throws -> [ExerciseTemplateModel] {
        guard !query.isEmpty else {
            return try await getAllTemplates()
        }
        let all = try await getAllTemplates()
        return all.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Custom Exercises

    func saveCustomTemplate(_ template: ExerciseTemplateModel) async throws {
        var templates = try await getCustomTemplates()
        templates.removeAll { $0.id == template.id }
        templates.append(template)

        let encoder = JSONEncoder()
        let data = try encoder.encode(templates)
        userDefaults.set(data, forKey: customTemplatesKey)
    }

    func deleteCustomTemplate(id: UUID) async throws {
        var templates = try await getCustomTemplates()
        templates.removeAll { $0.id == id }

        let encoder = JSONEncoder()
        let data = try encoder.encode(templates)
        userDefaults.set(data, forKey: customTemplatesKey)
    }

    private func getCustomTemplates() async throws -> [ExerciseTemplateModel] {
        guard let data = userDefaults.data(forKey: customTemplatesKey) else {
            return []
        }
        let decoder = JSONDecoder()
        return try decoder.decode([ExerciseTemplateModel].self, from: data)
    }

    // MARK: - History

    func getHistory() async throws -> [ExerciseHistoryModel] {
        guard let data = userDefaults.data(forKey: historyKey) else {
            return []
        }
        let decoder = JSONDecoder()
        return try decoder.decode([ExerciseHistoryModel].self, from: data)
    }

    func getRecentExercises(limit: Int) async throws -> [ExerciseHistoryModel] {
        let history = try await getHistory()
        return Array(history.sorted { $0.lastUsedDate > $1.lastUsedDate }.prefix(limit))
    }

    func getMostUsedExercises(limit: Int) async throws -> [ExerciseHistoryModel] {
        let history = try await getHistory()
        return Array(history.sorted { $0.useCount > $1.useCount }.prefix(limit))
    }

    func updateHistory(for templateId: UUID, exerciseName: String, weight: Double?, reps: Int?) async throws {
        var history = try await getHistory()

        if let index = history.firstIndex(where: { $0.templateId == templateId }) {
            history[index].lastUsedDate = Date()
            history[index].useCount += 1
            if let weight = weight {
                history[index].lastWeight = weight
            }
            if let reps = reps {
                history[index].lastReps = reps
            }
        } else {
            let newEntry = ExerciseHistoryModel(
                templateId: templateId,
                exerciseName: exerciseName,
                lastUsedDate: Date(),
                useCount: 1,
                lastWeight: weight,
                lastReps: reps
            )
            history.append(newEntry)
        }

        let encoder = JSONEncoder()
        let data = try encoder.encode(history)
        userDefaults.set(data, forKey: historyKey)
    }
}
