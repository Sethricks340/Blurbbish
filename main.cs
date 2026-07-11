using Godot;
// TODO: 
	// definitions for empty words in english_dictionary
	//
	// double ss detection? ex:
	// appless PASSED: 80.78%
	// appsles PASSED: 59.79%
	// applses PASSED: 40.54%
	// apples is a REAL word.
	// apple is a REAL word.

using System;
using System.Collections.Generic;
using System.Text.Json;

public partial class main : Node2D
{
	private static List<string> testWords;
	
	public override void _Ready()
	{	
		LoadTestWords();
		foreach (string word in testWords)
		{	
			(int type, double score) = Wordish.CheckWord(word);
			deconstruct_wordish(type, score, word);
		}
	}
	
	private static void deconstruct_wordish(int type, double score, string word){
		if (type == 0){
			GD.Print($"{word} is a REAL word.");	
		}
		if (type == 1){
			GD.Print($"{word} is a BLURBBED word.");	
		}
		if (type == 2){
			if (score > 0){
				GD.Print($"{word} PASSED: {score:F2}%");	
			}
			else{
				GD.Print($"{word} FAILED: {score:F2}%");	
			}
		}
	}
	
	private static void LoadTestWords()
	{
		testWords = LoadJson<List<string>>(
			"res://Data/test_words.json"
		);
	}

	private static T LoadJson<T>(string path)
	{
		using FileAccess file = FileAccess.Open(
			path,
			FileAccess.ModeFlags.Read
		);

		string json = file.GetAsText();

		return JsonSerializer.Deserialize<T>(json);
	}
}
