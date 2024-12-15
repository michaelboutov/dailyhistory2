import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/article.dart';

final beerHistoryArticle = Article(
  id: 'beer-history-${DateTime.now().millisecondsSinceEpoch}',
  title: 'The Ancient Origins of Beer: A Journey Through Time',
  content: '''
The story of beer is the story of human civilization itself. This beloved beverage, which has been a constant companion to humanity for thousands of years, has a history as rich and complex as its flavors.

The Dawn of Beer (10,000 BCE)
Archaeological evidence suggests that beer was first brewed as early as 10,000 BCE in Mesopotamia, modern-day Iraq. The Sumerians discovered that when grain got wet, it would ferment, creating a drink that would become one of humanity's oldest prepared beverages.

Ancient Egypt: Beer as Currency (4,000 BCE)
In ancient Egypt, beer was not just a drink but a form of currency. Workers building the pyramids were often paid in beer, receiving a daily ration of about 4-5 liters. The Egyptians believed beer was a gift from their gods and included it in religious ceremonies.

Medieval Monasteries: The Birth of Modern Brewing (500-1500 CE)
During the Middle Ages, European monasteries became the centers of brewing innovation. Monks were the first to add hops to beer, which both preserved the drink and added its characteristic bitter flavor. These monastery breweries established many of the brewing traditions we still follow today.

The Industrial Revolution: Beer Goes Global (1800s)
The Industrial Revolution transformed beer brewing from a local craft into a global industry. Innovations like artificial refrigeration, pasteurization, and the invention of the glass bottle allowed beer to be produced on a massive scale and shipped worldwide.

Modern Craft Beer Revolution (1970s-Present)
The late 20th century saw a revival of traditional brewing methods with the rise of craft breweries. This movement brought back diverse beer styles and experimental brewing techniques, leading to the vibrant beer culture we enjoy today.

Beer Today: A Global Cultural Phenomenon
Today, beer is the most widely consumed alcoholic beverage in the world. From traditional Belgian Trappist ales to American craft IPAs, beer continues to evolve while maintaining its ancient connection to human civilization.

The art of brewing beer remains a testament to human ingenuity and creativity, connecting us to our ancestors who first discovered this remarkable beverage thousands of years ago.
''',
  date: DateTime.now(),
  imageUrl: 'https://images.unsplash.com/photo-1436076863939-06870fe779c2',
  likeCount: 0,
);
