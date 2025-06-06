import 'package:equatable/equatable.dart';
import 'package:gigglio/data/data_models/post_model.dart';
import 'package:gigglio/data/data_models/user_details.dart';

class NotiDbModel extends Equatable {
  final String from;
  final String to;
  final DateTime dateTime;
  final String? postId;
  final NotiCategory category;

  const NotiDbModel({
    required this.from,
    required this.to,
    required this.dateTime,
    this.postId,
    required this.category,
  });

  factory NotiDbModel.fromJson(Map<String, dynamic> json) {
    return NotiDbModel(
      from: json['from'],
      to: json['to'],
      dateTime: DateTime.parse(json['date_time']),
      postId: json['post_id'],
      category: NotiCategory.values.firstWhere((e) {
        return e.id == json['category'];
      }),
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'date_time': dateTime.toIso8601String(),
        'post_id': postId,
        'category': category.id
      };

  @override
  List<Object?> get props => [from, to, dateTime, postId, category];
}

enum NotiCategory {
  like('like', title: 'Post Liked', desc: 'liked your post'),
  comment('comment', title: 'New Comment', desc: 'commented on your post'),
  request('request',
      title: 'New Friend Request', desc: 'requested to be friends with you'),
  reqAccepted('request-accepted',
      title: 'Request Accepted', desc: 'accepted your friend request'),
  ;

  const NotiCategory(this.id, {required this.title, required this.desc});
  final String title;
  final String desc;
  final String id;
}

class NotiModel extends Equatable {
  final UserDetails from;
  final String to;
  final DateTime dateTime;
  final PostDbModel? post;
  final NotiCategory category;

  const NotiModel({
    required this.from,
    required this.to,
    required this.dateTime,
    required this.post,
    required this.category,
  });

  factory NotiModel.fromDb({
    required UserDetails user,
    PostDbModel? post,
    required NotiDbModel noti,
  }) {
    return NotiModel(
      from: user,
      post: post,
      to: noti.to,
      dateTime: noti.dateTime,
      category: noti.category,
    );
  }

  @override
  List<Object?> get props => [from, to, dateTime, post, category];
}
