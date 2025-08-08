import '../models/news_article.dart';
import '../models/game.dart';
import '../models/merch_item.dart';
import '../models/fan_leaderboard.dart';
import '../models/fan_photo.dart';

class MockDataService {
  static List<NewsArticle> getNewsArticles() {
    return [
      NewsArticle(
        id: '1',
        title: 'Revenue Runners Dominate in Season Opener',
        content: 'The Miami Revenue Runners kicked off their season with an impressive victory, showcasing their offensive prowess and defensive strength.',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        author: 'Team Reporter',
        category: 'Game Recap',
      ),
      NewsArticle(
        id: '2',
        title: 'New Star Player Signs with Revenue Runners',
        content: 'Miami welcomes their newest addition to the roster, bringing fresh talent and energy to the team.',
        imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        author: 'Sports Desk',
        category: 'Team News',
        isVideo: true,
        videoUrl: 'https://example.com/video.mp4',
      ),
      NewsArticle(
        id: '3',
        title: 'Fan Meet & Greet Event Announced',
        content: 'Join us for an exclusive meet and greet with your favorite Revenue Runners players next weekend!',
        imageUrl: 'https://images.unsplash.com/photo-1511882150382-421056c89033?w=400',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        author: 'Events Team',
        category: 'Events',
      ),
    ];
  }

  static List<Game> getGames() {
    return [
      Game(
        id: '1',
        opponent: 'DC Sales Eagles',
        dateTime: DateTime.now().add(const Duration(days: 3)),
        venue: 'Miami Arena',
        isHome: true,
        status: 'upcoming',
      ),
      Game(
        id: '2',
        opponent: 'Chicago Sales Sharks',
        dateTime: DateTime.now().add(const Duration(days: 7)),
        venue: 'Chicago Stadium',
        isHome: false,
        status: 'upcoming',
      ),
      Game(
        id: '3',
        opponent: 'Denver Deal Dynamos',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        venue: 'Miami Arena',
        score: 'Revenue Runners 28 - Deal Dynamos 24',
        isHome: true,
        status: 'completed',
      ),
    ];
  }

  static List<MerchItem> getMerchItems() {
    return [
      MerchItem(
        id: '1',
        name: 'Revenue Runners Home Jersey',
        description: 'Official team jersey with player number and team logo',
        price: 89.99,
        imageUrl: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400',
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Blue', 'White'],
        category: 'Jerseys',
        stockQuantity: 50,
      ),
      MerchItem(
        id: '2',
        name: 'Team Logo Cap',
        description: 'Stylish cap with embroidered team logo',
        price: 24.99,
        imageUrl: 'https://images.unsplash.com/photo-1521369909029-2afed882baee?w=400',
        sizes: ['One Size'],
        colors: ['Blue', 'Black'],
        category: 'Hats',
        isOnSale: true,
        salePrice: 19.99,
        stockQuantity: 25,
      ),
      MerchItem(
        id: '3',
        name: 'Fan T-Shirt',
        description: 'Comfortable cotton t-shirt with team design',
        price: 29.99,
        imageUrl: 'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=400',
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['White', 'Gray'],
        category: 'T-Shirts',
        stockQuantity: 100,
      ),
    ];
  }

  static List<FanLeaderboard> getLeaderboard() {
    return [
      FanLeaderboard(
        id: '1',
        username: 'SuperFan_Mike',
        avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
        points: 2850,
        rank: 1,
        badge: '🏆 Champion',
        gamesAttended: 15,
        postsShared: 47,
      ),
      FanLeaderboard(
        id: '2',
        username: 'RunnersFan_Sarah',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
        points: 2340,
        rank: 2,
        badge: '🥈 Runner Up',
        gamesAttended: 12,
        postsShared: 38,
      ),
      FanLeaderboard(
        id: '3',
        username: 'MiamiLoyal_David',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        points: 1980,
        rank: 3,
        badge: '🥉 Bronze',
        gamesAttended: 10,
        postsShared: 29,
      ),
    ];
  }

  static List<FanPhoto> getFanPhotos() {
    return [
      FanPhoto(
        id: '1',
        username: 'FanCam_Emma',
        imageUrl: 'https://images.unsplash.com/photo-1511882150382-421056c89033?w=400',
        caption: 'Amazing atmosphere at tonight\'s game! #RevenueRunners #MiamiPride',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 4)),
        likes: 156,
        isFeatured: true,
        socialMediaUrl: 'https://instagram.com/p/example1',
      ),
      FanPhoto(
        id: '2',
        username: 'RunnersFan_John',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        caption: 'Best seats in the house! Go Runners! 🏈',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 89,
        socialMediaUrl: 'https://twitter.com/example2',
      ),
      FanPhoto(
        id: '3',
        username: 'MiamiSupporter_Lisa',
        imageUrl: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400',
        caption: 'Team spirit is everything! 💙',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        likes: 203,
        isFeatured: true,
        socialMediaUrl: 'https://tiktok.com/@example3',
      ),
    ];
  }

  static int getUserPoints() {
    return 1250;
  }

  static List<String> getUserBadges() {
    return ['🎯 First Game', '📸 Social Butterfly', '🛒 Merch Collector'];
  }
}
