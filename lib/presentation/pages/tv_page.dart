import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/constants.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/presentation/pages/now_playing_tv_page.dart';
import 'package:ditonton/presentation/pages/popular_tv_page.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/pages/search_tv_page.dart';
import 'package:ditonton/presentation/pages/top_rated_tv_page.dart';
import 'package:ditonton/presentation/pages/tv_detail_page.dart';
import 'package:ditonton/presentation/provider/tv_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TVPage extends StatefulWidget {
  static const ROUTE_NAME = '/tv';

  @override
  TVPageState createState() => TVPageState();
}

class TVPageState extends State<TVPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<TvListNotifier>(context, listen: false)
      ..fetchNowPlayingTv()
      ..fetchPopularTv()
      ..fetchTopRatedTv());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TV Page'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, SearchTvPage.ROUTE_NAME);
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubHeading(
                title: 'Now Playing',
                onTap: () =>
                    Navigator.pushNamed(context, NowPlayingTvPage.ROUTE_NAME),
              ),
              Consumer<TvListNotifier>(builder: (context, data, child) {
                final state = data.nowPlayingState;
                if (state == RequestState.Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state == RequestState.Loaded) {
                  return TVList(data.nowPlayingTv);
                } else {
                  return Text('Failed');
                }
              }),
              _buildSubHeading(
                title: 'Popular',
                onTap: () =>
                    Navigator.pushNamed(context, PopularTvPage.ROUTE_NAME),
              ),
              Consumer<TvListNotifier>(builder: (context, data, child) {
                final state = data.popularTvState;
                if (state == RequestState.Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state == RequestState.Loaded) {
                  return TVList(data.popularTv);
                } else {
                  return Text('Failed');
                }
              }),
              _buildSubHeading(
                title: 'Top Rated',
                onTap: () =>
                    Navigator.pushNamed(context, TopRatedTvPage.ROUTE_NAME),
              ),
              Consumer<TvListNotifier>(builder: (context, data, child) {
                final state = data.topRatedTvState;
                if (state == RequestState.Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state == RequestState.Loaded) {
                  return TVList(data.topRatedTv);
                } else {
                  return Text('Failed');
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildSubHeading({required String title, required Function() onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: titleLarge,
        ),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [Text('See More'), Icon(Icons.arrow_forward_ios)],
            ),
          ),
        ),
      ],
    );
  }
}

class TVList extends StatelessWidget {
  final List<Tv> tvs;

  TVList(this.tvs);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 3,
            childAspectRatio: 1.3),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final tv = tvs[index];
          return Stack(
            children: [
              Container(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      TvDetailPage.ROUTE_NAME,
                      arguments: tv.id,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: '$BASE_IMAGE_URL${tv.posterPath}',
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.black38,
                width: double.infinity,
                height: 50,
                child: Text(
                  '${tv.name}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          );
        },
        itemCount: (tvs.length > 10) ? 10 : tvs.length,
      ),
    );
  }
}
