## PlanetData - Resource définissant une planète
##
## Contient toutes les données d'une planète:
## - Informations d'affichage
## - Configuration des vagues
## - Données du boss
class_name PlanetData
extends Resource

## Identifiant unique de la planète
@export var id: StringName = &"mercury"

## Nom d'affichage
@export var display_name: String = "Mercury"

## Couleur thématique de la planète
@export var theme_color: Color = Color.ORANGE_RED

## Couleur de fond
@export var background_color: Color = Color(0.15, 0.05, 0.0)

## Description courte
@export_multiline var description: String = ""

## Difficulté (1-4)
@export_range(1, 4) var difficulty: int = 1

## Données des vagues (5 vagues normales)
@export var waves: Array[WaveData] = []

## Données du boss
@export var boss_wave: WaveData = null

## Monnaie bonus à la complétion
@export var completion_bonus: int = 100
