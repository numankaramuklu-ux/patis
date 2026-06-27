// Bu oturumda eklenen depoların (store) unit testleri.
//
// Hepsi açılışta SharedPreferences okuduğu için boş bir mock yeterli; testler
// bellek içi (seed) durum üzerinde public API'yi doğrular.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:petapp/models/dog_walk.dart';
import 'package:petapp/models/review.dart';
import 'package:petapp/models/service_provider.dart';
import 'package:petapp/state/message_store.dart';
import 'package:petapp/state/pet_walker_store.dart';
import 'package:petapp/state/review_store.dart';
import 'package:petapp/state/service_provider_store.dart';
import 'package:petapp/state/walk_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WalkStore', () {
    test('yeni yürüyüş eklenir ve bekleyen sayısı artar', () {
      final store = WalkStore();
      final before = store.pendingCount;
      store.add(
        DogWalk(
          id: 'tw1',
          ownerName: 'Test',
          petName: 'Pati',
          breed: 'Terrier',
          date: DateTime.now(),
          time: '10:00',
          durationMin: 30,
          price: 100,
          status: WalkStatus.bekliyor,
        ),
      );
      expect(store.pendingCount, before + 1);
      expect(store.walks.any((w) => w.id == 'tw1'), isTrue);
    });

    test('durum güncellenince bekleyenden çıkar, kazanca eklenir', () {
      final store = WalkStore();
      store.add(
        DogWalk(
          id: 'tw2',
          ownerName: 'Test',
          petName: 'Pati',
          breed: 'Terrier',
          date: DateTime.now(),
          time: '11:00',
          durationMin: 45,
          price: 200,
          status: WalkStatus.bekliyor,
        ),
      );
      final pendingBefore = store.pendingCount;
      final earningsBefore = store.projectedEarnings;

      store.updateStatus('tw2', WalkStatus.onaylandi);

      expect(store.pendingCount, pendingBefore - 1);
      expect(store.projectedEarnings, earningsBefore + 200);
    });
  });

  group('ReviewStore', () {
    test('yorum eklenince hedefin sayısı ve ortalaması güncellenir', () {
      final store = ReviewStore();
      const target = 'x1';
      expect(store.countFor(target), 0);

      store.add(const Review(
        id: 'a',
        targetId: target,
        author: 'A',
        rating: 4,
        comment: 'iyi',
      ));
      store.add(const Review(
        id: 'b',
        targetId: target,
        author: 'B',
        rating: 2,
        comment: 'fena',
      ));

      expect(store.countFor(target), 2);
      expect(store.averageFor(target), 3.0);
      expect(store.forTarget(target).length, 2);
    });

    test('farklı hedeflerin yorumları karışmaz', () {
      final store = ReviewStore();
      store.add(const Review(
          id: 'a', targetId: 't1', author: 'A', rating: 5, comment: 'x'));
      store.add(const Review(
          id: 'b', targetId: 't2', author: 'B', rating: 1, comment: 'y'));
      expect(store.countFor('t1'), 1);
      expect(store.countFor('t2'), 1);
      expect(store.averageFor('t1'), 5.0);
    });
  });

  group('MessageStore', () {
    test('seed sohbette okunmamış mesajlar var', () {
      final store = MessageStore();
      expect(store.unreadOf('t_elifk_petwalker'), greaterThan(0));
      expect(store.totalUnread, greaterThan(0));
    });

    test('openThread var olanı döndürür, yenisini oluşturur', () {
      final store = MessageStore();
      // Aynı ad + rol → var olan seed sohbeti döner.
      final existing =
          store.openThread(peerName: 'Elif K.', peerRole: 'Pet walker');
      expect(existing, 't_elifk_petwalker');

      final created =
          store.openThread(peerName: 'Yeni Kişi', peerRole: 'Pet walker');
      expect(store.threads.any((t) => t.id == created), isTrue);
    });

    test('aynı ad farklı rol → ayrı sohbetler', () {
      final store = MessageStore();
      final a =
          store.openThread(peerName: 'Ayşe Yılmaz', peerRole: 'Müşteri · Pamuk');
      final b =
          store.openThread(peerName: 'Ayşe Yılmaz', peerRole: 'Kayıp · Boncuk');
      expect(a, isNot(b));
    });

    test('mesaj gönderilir ve okundu işaretlenir', () {
      final store = MessageStore();
      final id = store.openThread(peerName: 'Burak', peerRole: 'Pet walker');
      store.send(id, 'merhaba');
      expect(store.messagesOf(id).last.body, 'merhaba');
      expect(store.messagesOf(id).last.fromMe, isTrue);

      store.markThreadRead('t_elifk_petwalker');
      expect(store.unreadOf('t_elifk_petwalker'), 0);
    });

    test('boş mesaj gönderilmez', () {
      final store = MessageStore();
      final id = store.openThread(peerName: 'Boş', peerRole: 'x');
      store.send(id, '   ');
      expect(store.messagesOf(id), isEmpty);
    });
  });

  group('PetWalkerStore', () {
    test('seed gezdiriciler yüklenir', () {
      final store = PetWalkerStore();
      expect(store.walkers, isNotEmpty);
    });

    test('favori eklenip çıkarılır', () {
      final store = PetWalkerStore();
      final id = store.walkers.first.id;
      expect(store.isFavorite(id), isFalse);
      store.toggleFavorite(id);
      expect(store.isFavorite(id), isTrue);
      expect(store.favoriteCount, 1);
      store.toggleFavorite(id);
      expect(store.isFavorite(id), isFalse);
    });
  });

  group('ServiceProviderStore', () {
    test('türe göre filtreler', () {
      final store = ServiceProviderStore();
      final vets = store.byKind(ProviderKind.veteriner);
      final groomers = store.byKind(ProviderKind.kuafor);
      expect(vets, isNotEmpty);
      expect(groomers, isNotEmpty);
      expect(vets.every((p) => p.kind == ProviderKind.veteriner), isTrue);
      expect(groomers.every((p) => p.kind == ProviderKind.kuafor), isTrue);
    });

    test('byId doğru kaydı döndürür, yoksa null', () {
      final store = ServiceProviderStore();
      final first = store.byKind(ProviderKind.veteriner).first;
      expect(store.byId(first.id)?.id, first.id);
      expect(store.byId('yok-boyle-id'), isNull);
    });
  });
}
