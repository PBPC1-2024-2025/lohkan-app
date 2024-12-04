import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FoodPage extends StatefulWidget {
  final food;
  const FoodPage({super.key, this.food});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final _controller = ScrollController();
  var _bookMarkColor = 0x66550000;
  @override
  void initState() {
    super.initState();

    // Setup the listener.
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (!isTop) {
          setState(() {
            _bookMarkColor = 0xFF550000;
          });
        }
      } else {
        setState(() {
          _bookMarkColor = 0x66550000;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _foodType = 'Main Course';
    var _typeColor = Colors.green.shade400;
    if (widget.food.fields.type.toString() == 'Type.MC') {
      _foodType = 'Main Course';
      _typeColor = Colors.green.shade400;
    } else if (widget.food.fields.type.toString() == 'Type.DS') {
      _foodType = 'Dessert';
      _typeColor = Colors.yellow.shade400;
    } else if (widget.food.fields.type.toString() == 'Type.DR') {
      _foodType = 'Drinks';
      _typeColor = Colors.pink.shade400;
    } else if (widget.food.fields.type.toString() == 'Type.SN') {
      _foodType = 'Snacks';
      _typeColor = Colors.red.shade400;
    }
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Container(
            width: MediaQuery.of(context).size.width * 1,
            child: Row(
              children: [
                Text(
                  "${widget.food.fields.name}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900),
                )
              ],
            ),
          ),
        ),
        extendBody: true,
        body: ListView(
          controller: _controller,
          children: [
            CachedNetworkImage(
                // imageUrl: widget.food.fields.imageLink,
                imageUrl:
                    'https://asset.kompas.com/crops/N8WTCiVClutwEkjIgCykYbt1e2Q=/142x72:863x553/1200x800/data/photo/2022/09/27/633297e88244b.jpg',
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.food.fields.name}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${widget.food.fields.description}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Category:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          _foodType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Price:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          'Rp${widget.food.fields.minPrice} - Rp${widget.food.fields.maxPrice}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => {},
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(_bookMarkColor),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: const Color(0x66696969),
                            spreadRadius: 0,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ]),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Icon(
                        Icons.bookmark_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
