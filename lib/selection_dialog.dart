import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final TextStyle textStyle;
  final WidgetBuilder emptySearchBuilder;
  final bool showFlag;
  final double flagWidth;
  final Size size;
  final bool hideSearch;
  final String title;
  final TextEditingController controller;

  /// elements passed as favorite
  final List<CountryCode> favoriteElements;

  SelectionDialog(
    this.title,
    this.controller,
    this.elements,
    this.favoriteElements, {
    Key key,
    this.showCountryOnly,
    this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.textStyle,
    this.showFlag,
    this.flagWidth = 32,
    this.size,
    this.hideSearch = false,
  })  : assert(searchDecoration != null, 'searchDecoration must not be null!'),
        this.searchDecoration =
            searchDecoration.copyWith(prefixIcon: Icon(Icons.search)),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  List<CountryCode> filteredElements;

  @override
  Widget build(BuildContext context) => Container(
        width: widget.size?.width ?? MediaQuery.of(context).size.width,
        height: widget.size?.height ?? MediaQuery.of(context).size.height * 0.7,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(widget.title),
            ),
            body: NotificationListener<UserScrollNotification>(
              onNotification: (_) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(children: [
                if (!widget.hideSearch) Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: widget.controller,
                    style: widget.searchStyle,
                    decoration: widget.searchDecoration,
                    onChanged: _filterElements,
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: ListView(
                    children: [
                      widget.favoriteElements.isEmpty
                          ? const DecoratedBox(decoration: BoxDecoration())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...widget.favoriteElements.map(
                                  (f) => _buildOption(f),
                                ),
                                const Divider(),
                              ],
                            ),
                      if (filteredElements.isEmpty)
                        _buildEmptySearchWidget(context)
                      else
                        ...filteredElements.map(
                          (e) => _buildOption(e),
                        ),
                    ],
                  ),
                ))
              ]),
            )),
      );

  Widget _buildOption(CountryCode e) {
    return ListTile(
      key: Key(e.toLongString()),
      leading: Image.asset(
        e.flagUri,
        package: 'country_code_picker',
        width: widget.flagWidth,
      ),
      onTap: () => _selectItem(e),
      title: Text(
        widget.showCountryOnly ? e.toCountryStringOnly() : e.toLongString(),
        overflow: TextOverflow.fade,
        style: widget.textStyle,
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder(context);
    }

    return Center(
      child: Text('No country found'),
    );
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
              e.code.contains(s) ||
              e.dialCode.contains(s) ||
              e.name.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    Navigator.pop(context, e);
  }
}
