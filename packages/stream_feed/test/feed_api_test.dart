import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:stream_feed_dart/src/core/api/feed_api_impl.dart';
import 'package:stream_feed_dart/src/core/http/http_client.dart';
import 'package:stream_feed_dart/src/core/http/token.dart';
import 'package:stream_feed_dart/src/core/models/feed_id.dart';
import 'package:stream_feed_dart/src/core/util/default.dart';
import 'package:stream_feed_dart/src/core/util/routes.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements HttpClient {}

Future<void> main() async {
  group('Feed API', () {
    final mockClient = MockHttpClient();
    test('Follow', () async {
      const token = Token('dummyToken');
      const targetToken = Token('dummyToken2');

      final feedApi = FeedApiImpl(mockClient);
      final sourceFeed = FeedId('global', 'feed1');
      final targetFeed = FeedId('global', 'feed2');
      const activityCopyLimit = 10;
      when(mockClient.post(
        Routes.buildFeedUrl(sourceFeed, 'following'),
        headers: {'Authorization': '$token'},
        data: {
          'target': '$targetFeed',
          'activity_copy_limit': activityCopyLimit,
          'target_token': '$targetToken',
        },
      )).thenAnswer((_) async => Response(data: {}, statusCode: 200));

      await feedApi.follow(
          token, targetToken, sourceFeed, targetFeed, activityCopyLimit);

      verify(mockClient.post(
        Routes.buildFeedUrl(sourceFeed, 'following'),
        headers: {'Authorization': '$token'},
        data: {
          'target': '$targetFeed',
          'activity_copy_limit': activityCopyLimit,
          'target_token': '$targetToken',
        },
      )).called(1);
    });

    test('GetEnrichedActivities', () async {
      const token = Token('dummyToken');

      final feedApi = FeedApiImpl(mockClient);
      final feed = FeedId('global', 'feed1');

      final options = {
        'limit': Default.limit,
        'offset': Default.offset,
        ...Default.filter.params,
        ...Default.enrichmentFlags.params,
        ...Default.marker.params
      };

      when(mockClient.get(
        Routes.buildEnrichedFeedUrl(feed),
        headers: {'Authorization': '$token'},
        queryParameters: options,
      )).thenAnswer((_) async => Response(data: {}, statusCode: 200));

      await feedApi.getEnrichedActivities(token, feed, options);

      verify(mockClient.get(
        Routes.buildEnrichedFeedUrl(feed),
        headers: {'Authorization': '$token'},
        queryParameters: options,
      )).called(1);
    });

    test('RemoveActivityByForeignId', () async {
      const token = Token('dummyToken');

      final feedApi = FeedApiImpl(mockClient);
      final feed = FeedId('global', 'feed1');

      const foreignId = 'foreignId';
      when(mockClient.delete(
        Routes.buildFeedUrl(feed, foreignId),
        headers: {'Authorization': '$token'},
        queryParameters: {'foreign_id': '1'},
      )).thenAnswer((_) async => Response(data: {}, statusCode: 200));

      await feedApi.removeActivityByForeignId(token, feed, foreignId);

      verify(mockClient.delete(
        Routes.buildFeedUrl(feed, foreignId),
        headers: {'Authorization': '$token'},
        queryParameters: {'foreign_id': '1'},
      )).called(1);
    });

    test('RemoveActivityById', () async {
      const token = Token('dummyToken');

      final feedApi = FeedApiImpl(mockClient);
      final feed = FeedId('global', 'feed1');

      const id = 'id';
      when(mockClient.delete(
        Routes.buildFeedUrl(feed, id),
        headers: {'Authorization': '$token'},
      )).thenAnswer((_) async => Response(data: {}, statusCode: 200));

      await feedApi.removeActivityById(token, feed, id);

      verify(mockClient.delete(
        Routes.buildFeedUrl(feed, id),
        headers: {'Authorization': '$token'},
      )).called(1);
    });

    test('UnFollow', () async {
      const token = Token('dummyToken');

      final feedApi = FeedApiImpl(mockClient);
      final source = FeedId('global', 'feed1');
      final target = FeedId('global', 'feed2');
      const keepHistory = true;

      when(mockClient.delete(
        Routes.buildFeedUrl(source, 'following/$target'),
        headers: {'Authorization': '$token'},
        queryParameters: {'keep_history': keepHistory},
      )).thenAnswer((_) async => Response(data: {}, statusCode: 200));

      await feedApi.unfollow(token, source, target, keepHistory);

      verify(mockClient.delete(
        Routes.buildFeedUrl(source, 'following/$target'),
        headers: {'Authorization': '$token'},
        queryParameters: {'keep_history': keepHistory},
      )).called(1);
    });
  });
}
