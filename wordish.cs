using Godot;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Linq;

public static class Wordish
{
	private static Dictionary<string, string[]> wordDefinitions;
	private static Dictionary<string, string[]> blurbbinary;
	private static Dictionary<string, Dictionary<string, int>> gramsDict;
	private static readonly int[] maxCounts = { 40163, 15754, 6764, 4796 };
	private static readonly int[] gramWeights = { 5, 9, 5, 2 };
	
	private class GramScoreResult
	{
		public double ExistingScore;
		public double FrequencyScore;
		public Dictionary<string, int> Grams;

		public GramScoreResult(
			double existingScore,
			double frequencyScore,
			Dictionary<string, int> grams)
		{
			ExistingScore = existingScore;
			FrequencyScore = frequencyScore;
			Grams = grams;
		}
	}

	static Wordish()
	{
		LoadData();
	}
	
	public static (int, double) CheckWord(string word)
	{
		word = word.ToLower().Trim();

		// 0 = real word, 1 = in Blurbbinary, 2 = new word
		if (wordDefinitions.ContainsKey(word)) { 
			return (0,0);
		}
		if (blurbbinary.ContainsKey(word)){ 
			return (1,0); 
		}
			
		return (2,WordishScore(word));
	}

	private static void LoadData()
	{
		wordDefinitions = LoadJson<Dictionary<string, string[]>>(
			"res://Data/english_dictionary.json"
		);

		blurbbinary = LoadJson<Dictionary<string, string[]>>(
			"res://Data/blurbbinary.json"
		);

		gramsDict = LoadJson<Dictionary<string, Dictionary<string, int>>>(
			"res://Data/grams.json"
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
	
	private static GramScoreResult GetGramScores(string word)
	{
		// Return existence of the gram in English scores and frequency scores for a word

		List<double> weightedFreqScores = new List<double>();
		List<int> weightedExistingScores = new List<int>();

		Dictionary<string, int> grams = new Dictionary<string, int>();


		for (int group = 2; group <= 5; group++) // 2 to 5
		{
			for (int index = 0; index < word.Length - (group - 1); index++)
			{
				string letters = word.Substring(index, group);


				if (gramsDict.ContainsKey(letters))
				{
					weightedExistingScores.Add(
						gramWeights[group - 2]
					);


					double weightedFreqScore =
						Math.Log(
							gramsDict[letters].Values.Sum() + 1
						)
						/
						Math.Log(
							maxCounts[group - 2] + 1
						);


					weightedFreqScores.Add(
						weightedFreqScore * gramWeights[group - 2]
					);
				}
				else
				{
					weightedExistingScores.Add(0);
					weightedFreqScores.Add(0);
				}


				if (grams.ContainsKey(letters))
				{
					grams[letters] += 1;
				}
				else
				{
					grams[letters] = 0;
				}
			}
		}


		double denominator = 0;

		for (int group = 2; group <= 5; group++)
		{
			for (int i = 0; i < word.Length - (group - 1); i++)
			{
				denominator += gramWeights[group - 2];
			}
		}


		double existingScore =
			weightedExistingScores.Sum()
			/
			denominator
			*
			100;


		double frequencyScore =
			weightedFreqScores.Sum()
			/
			denominator
			*
			100;


		return new GramScoreResult(
			existingScore,
			frequencyScore,
			grams
		);
	}
	private static int RepetitionScore(Dictionary<string, int> grams)
	{
		// Penalize repeated grams in the word

		int score = 0;


		foreach (int value in grams.Values)
		{
			score += value;
		}


		if (score == 0)
		{
			return 0;
		}
		else if (score > 5)
		{
			return -50;
		}
		else
		{
			return -15;
		}
	}
	
	private static int RepeatedLetterScore(string word)
	{
		// Return a penalty if the word contains three identical letters in a row

		int repeatCount = 1;


		for (int i = 1; i < word.Length; i++)
		{
			if (word[i] == word[i - 1])
			{
				repeatCount++;
			}
			else
			{
				repeatCount = 1;
			}


			if (repeatCount >= 3)
			{
				return -100;
			}
		}


		return 0;
	}
	
	private static int VowelConsonantScore(string word)
	{
		// Return a penalty if the word has only vowels or only consonants

		string vowels = "aeiou";

		int vowelCount = 0;
		int consonantCount = 0;


		foreach (char letter in word)
		{
			if (vowels.Contains(letter))
			{
				vowelCount++;
			}
			else
			{
				consonantCount++;
			}
		}


		if (vowelCount == 0 || consonantCount == 0)
		{
			return -100;
		}


		return 0;
	}
	
	private static double GramLocationsScore(string word, Dictionary<string, int> grams)
	{
		// Score and penalize grams by their typical position in real words

		List<double> penalties = new List<double>();


		foreach (string gram in grams.Keys)
		{
			int length = gram.Length;


			// only bigram and trigrams, since most quadgrams and quintgrams won't exist
			if (!(length == 2 || length == 3))
			{
				continue;
			}
			else
			{
				int start = word.IndexOf(gram);
				int end = start + gram.Length;


				string position;


				if (start == 0 && end == word.Length)
				{
					position = "middle";
				}

				else if (start == 0)
				{
					position = "beginning";
				}

				else if (end == word.Length)
				{
					position = "end";
				}

				else
				{
					position = "middle";
				}


				if (gramsDict.ContainsKey(gram))
				{
					int count = gramsDict[gram][position];

					int total = gramsDict[gram].Values.Sum();

					double probability = (double)count / total;

					double penalty = Math.Log10(probability + 0.01) * 20;

					penalties.Add(penalty);
				}
				else
				{
					// if a bi or tri gram doesn't exist entirely, punish it greatly
					penalties.Add(-200);
				}
			}
		}


		if (penalties.Count == 0)
		{
			return 0;
		}


		return penalties.Sum() / penalties.Count;
	}
	
	private static int ZWordScore(string word)
	{
		// Remove z from beginning
		if (word.StartsWith("z") &&
			wordDefinitions.ContainsKey(word.Substring(1)))
		{
			return 0;
		}


		// Remove z from end
		if (word.EndsWith("z") &&
			wordDefinitions.ContainsKey(word.Substring(0, word.Length - 1)))
		{
			return 0;
		}


		// Remove all trailing z's
		string stripped = word.TrimEnd('z');

		if (stripped != word &&
			wordDefinitions.ContainsKey(stripped))
		{
			return 0;
		}


		// Remove doubled z
		if (word.Contains("zz"))
		{
			if (wordDefinitions.ContainsKey(word.Replace("zz", "ss")))
			{
				return 0;
			}
		}


		// Replace z with "es"
		if (wordDefinitions.ContainsKey(word.Replace("z", "es")))
		{
			return 0;
		}


		// Replace z with "gs"
		if (wordDefinitions.ContainsKey(word.Replace("z", "gs")))
		{
			return 0;
		}


		// Replace z with "g"
		if (wordDefinitions.ContainsKey(word.Replace("z", "g")))
		{
			return 0;
		}


		// Remove z's and check if the base word exists
		string noZ = word.Replace("z", "");

		if (noZ != word &&
			wordDefinitions.ContainsKey(noZ))
		{
			return 0;
		}


		return 100;
	}
	
	private static double WordishScore(string word)
	{
		// Combine gram-based evidence and penalties into a single score


		if (ZWordScore(word) == 0)
		{
			return 0;
		}


		GramScoreResult gramResult = GetGramScores(word);

		double existingScore = gramResult.ExistingScore;
		double frequencyScore = gramResult.FrequencyScore;
		Dictionary<string, int> grams = gramResult.Grams;


		int repeatPenalty = RepetitionScore(grams);
		int triplePenalty = RepeatedLetterScore(word);
		int vowelPenalty = VowelConsonantScore(word);
		double gramLocationPenalty = GramLocationsScore(word, grams);



		// Positive evidence
		double score =
			existingScore * 0.5 +
			frequencyScore * 0.5;



		// Negative evidence
		score += repeatPenalty;
		score += triplePenalty;
		score += vowelPenalty;
		score += gramLocationPenalty;



		return Math.Max(score, 0);
	}
}
