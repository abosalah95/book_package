import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    title: 'Syncfusion PDF Viewer Demo',
    home: HomePage(),
  ));
}

/// Represents Homepage for Navigation
class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late PdfViewerController _pdfViewerController;
  Uint8List? _documentBytes;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    getPdfBytes();

    super.initState();
  }

  ///Get the PDF document as bytes.
  void getPdfBytes() async {
    _documentBytes = await http.readBytes(Uri.parse('https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf'));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Flutter PDF Viewer'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.bookmark,
                color: Colors.white,
                semanticLabel: 'Bookmark',
              ),
              onPressed: () {
                _pdfViewerKey.currentState?.openBookmarkView();
              },
            ),
          ],
        ),
        body: Semantics(
          label: "test",
          enabled: true,
          onTap: () {
            print('tatattatatt');
          },
          button: true,
          child: _documentBytes != null
              ? SfPdfViewerTheme(
               data: SfPdfViewerThemeData(
                scrollHeadStyle:
                const PdfScrollHeadStyle(
                    backgroundColor: Colors.greenAccent
                )),
                child: SfPdfViewer.memory(
                    _documentBytes!,
                    pageLayoutMode: PdfPageLayoutMode.single,
                    scrollDirection: PdfScrollDirection.horizontal,
                    key: _pdfViewerKey,
                    interactionMode: PdfInteractionMode.pan,
                    onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                      if (details.selectedText == null && _overlayEntry != null) {
                        _overlayEntry!.remove();
                        _overlayEntry = null;
                      } else if (details.selectedText != null && _overlayEntry == null) {
                        _showContextMenu(context, details);
                      }
                    },
                    controller: _pdfViewerController,
                  ),
              )
              : Container(),
        ));
  }

  // void _showContextMenu(
  //     BuildContext context, PdfTextSelectionChangedDetails details) {
  //   final OverlayState _overlayState = Overlay.of(context)!;
  //   _overlayEntry = OverlayEntry(
  //
  //     builder: (context) => Positioned(
  //       top: details.globalSelectedRegion!.center.dy - 55,
  //       left: details.globalSelectedRegion!.bottomLeft.dx,
  //       child: RaisedButton(
  //         onPressed: () {
  //           Clipboard.setData(ClipboardData(text: details.selectedText));
  //           print(
  //               'Text copied to clipboard: ' + details.selectedText.toString());
  //           _pdfViewerController.clearSelection();
  //         },
  //         color: Colors.white,
  //         elevation: 10,
  //         child: Text('add actions', style: TextStyle(fontSize: 17)),
  //       ),
  //     ),
  //   );
  //   _overlayState.insert(_overlayEntry!);
  // }

  /// Show Context menu with annotation options.
  void _showContextMenu(
    BuildContext context,
    PdfTextSelectionChangedDetails? details,
  ) {
    final RenderBox? renderBoxContainer = context.findRenderObject()! as RenderBox;
    if (renderBoxContainer != null) {
      final double _kContextMenuHeight = 90;
      final double _kContextMenuWidth = 100;
      final double _kHeight = 18;
      final Offset containerOffset = renderBoxContainer.localToGlobal(
        renderBoxContainer.paintBounds.topLeft,
      );
      if (details != null && containerOffset.dy < details.globalSelectedRegion!.topLeft.dy ||
          (containerOffset.dy < (details!.globalSelectedRegion!.center.dy - (_kContextMenuHeight / 2)) &&
              details.globalSelectedRegion!.height > _kContextMenuWidth)) {
        double top = 0.0;
        double left = 0.0;
        final Rect globalSelectedRect = details.globalSelectedRegion!;
        if ((globalSelectedRect.top) > MediaQuery.of(context).size.height / 2) {
          top = globalSelectedRect.topLeft.dy + details.globalSelectedRegion!.height + _kHeight;
          left = globalSelectedRect.bottomLeft.dx;
        } else {
          top = globalSelectedRect.height > _kContextMenuWidth
              ? globalSelectedRect.center.dy - (_kContextMenuHeight / 2)
              : globalSelectedRect.topLeft.dy + details.globalSelectedRegion!.height + _kHeight;
          left = globalSelectedRect.height > _kContextMenuWidth ? globalSelectedRect.center.dx - (_kContextMenuWidth / 2) : globalSelectedRect.bottomLeft.dx;
        }
        final OverlayState? _overlayState = Overlay.of(context, rootOverlay: true);
        _overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: top,
            left: left,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.14),
                    blurRadius: 2,
                    offset: Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              constraints: BoxConstraints.tightFor(width: _kContextMenuWidth, height: _kContextMenuHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _addAnnotation('Highlight', details.selectedText),
                  // _addAnnotation('Underline', details.selectedText),
                  // _addAnnotation('Strikethrough', details.selectedText),
                  _addAnnotation('bookmark', details.selectedText),
                  _addAnnotation('rectangle', details.selectedText),

                ],
              ),
            ),
          ),
        );
        _overlayState?.insert(_overlayEntry!);
      }
    }
  }

  /// Check and close the context menu.
  void _checkAndCloseContextMenu() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  ///Add the annotation in a PDF document.
  Widget _addAnnotation(String? annotationType, String? selectedText) {
    return Container(
      height: 30,
      width: 100,
      child: RawMaterialButton(
        onPressed: () async {
          _checkAndCloseContextMenu();
          await Clipboard.setData(ClipboardData(text: selectedText));
          _drawAnnotation(annotationType);
        },
        child: Text(
          annotationType!,
          style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'Roboto', fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  ///Draw the annotation in a PDF document.
  void _drawAnnotation(String? annotationType) {
    final PdfDocument document = PdfDocument(inputBytes: _documentBytes);
    switch (annotationType) {
      case 'Highlight':
        {
          _pdfViewerKey.currentState!.getSelectedTextLines().forEach((pdfTextLine) {
            final PdfPage _page = document.pages[pdfTextLine.pageNumber];
            final PdfRectangleAnnotation rectangleAnnotation = PdfRectangleAnnotation(pdfTextLine.bounds, 'Highlight Annotation',
                author: 'Syncfusion', color: PdfColor.fromCMYK(0, 0, 255, 0), innerColor: PdfColor.fromCMYK(0, 0, 255, 0), opacity: 0.5);
            _page.annotations.add(rectangleAnnotation);
            _page.annotations.flattenAllAnnotations();
            // xOffset = _pdfViewerController.scrollOffset.dx;
            // yOffset = _pdfViewerController.scrollOffset.dy;
          });
          final List<int> bytes = document.saveSync();
          setState(() {
            int page = _pdfViewerController.pageNumber;
            print ( page);
            _documentBytes = Uint8List.fromList(bytes);
            _pdfViewerController.jumpToPage(page);
          });
        }
        break;
      case 'Underline':
        {
          _pdfViewerKey.currentState!.getSelectedTextLines().forEach((pdfTextLine) {
            final PdfPage _page = document.pages[pdfTextLine.pageNumber];
            final PdfLineAnnotation lineAnnotation = PdfLineAnnotation(
              [
                pdfTextLine.bounds.left.toInt(),
                (document.pages[pdfTextLine.pageNumber].size.height - pdfTextLine.bounds.bottom).toInt(),
                pdfTextLine.bounds.right.toInt(),
                (document.pages[pdfTextLine.pageNumber].size.height - pdfTextLine.bounds.bottom).toInt()
              ],
              'Underline Annotation',
              author: 'Syncfusion',
              innerColor: PdfColor(0, 255, 0),
              color: PdfColor(0, 255, 0),
            );
            _page.annotations.add(lineAnnotation);
            _page.annotations.flattenAllAnnotations();
            // xOffset = _pdfViewerController.scrollOffset.dx;
            // yOffset = _pdfViewerController.scrollOffset.dy;
          });
          final List<int> bytes = document.saveSync();
          setState(() {
            _documentBytes = Uint8List.fromList(bytes);
          });
        }
        break;
      case 'Strikethrough':
        {
          _pdfViewerKey.currentState!.getSelectedTextLines().forEach((pdfTextLine) {
            final PdfPage _page = document.pages[pdfTextLine.pageNumber];
            final PdfLineAnnotation lineAnnotation = PdfLineAnnotation(
              [
                pdfTextLine.bounds.left.toInt(),
                ((document.pages[pdfTextLine.pageNumber].size.height - pdfTextLine.bounds.bottom) + (pdfTextLine.bounds.height / 2)).toInt(),
                pdfTextLine.bounds.right.toInt(),
                ((document.pages[pdfTextLine.pageNumber].size.height - pdfTextLine.bounds.bottom) + (pdfTextLine.bounds.height / 2)).toInt()
              ],
              'Strikethrough Annotation',
              author: 'Syncfusion',
              innerColor: PdfColor(255, 0, 0),
              color: PdfColor(255, 0, 0),
            );
            _page.annotations.add(lineAnnotation);
            _page.annotations.flattenAllAnnotations();
            // xOffset = _pdfViewerController.scrollOffset.dx;
            // yOffset = _pdfViewerController.scrollOffset.dy;
          });
          final List<int> bytes = document.saveSync();
          setState(() {
            _documentBytes = Uint8List.fromList(bytes);
          });
        }
        break;
      case 'bookmark':
        {
          final PdfPage page = document.pages[_pdfViewerController.pageNumber];
          PdfBookmark bookmark = document.bookmarks.add('Chapter 1');
          //Sets the destination page and locaiton
          bookmark.destination = PdfDestination(page, Offset(10, 10));
          //Draw the content in the PDF page
          page.graphics.drawString(
              'Chapter1', PdfStandardFont(PdfFontFamily.helvetica, 10),
              brush: PdfBrushes.red, bounds: Rect.fromLTWH(10, 10, 0, 0));
          //Adds the child bookmark
          PdfBookmark childBookmark = bookmark.insert(0, 'Section 1');
          childBookmark.destination = PdfDestination(page, Offset(30, 30));
          //Draw the content in the PDF page
          page.graphics.drawString(
              'Section1', PdfStandardFont(PdfFontFamily.helvetica, 10),
              brush: PdfBrushes.green, bounds: Rect.fromLTWH(30, 30, 0, 0));
          //Sets the text style and color
          bookmark.textStyle = [PdfTextStyle.bold];
          bookmark.color = PdfColor(255, 0, 0);
          //Save the document
          final List<int> bytes = document.saveSync();
          setState(() {
            _documentBytes = Uint8List.fromList(bytes);
          });
            }
      break;
      case 'rectangle':
        {
          //Draw the rectangle on PDF document
          document.pages.add().graphics.drawRectangle(
          brush: PdfBrushes.orange, bounds: Rect.fromLTWH(100, 100, 100, 50));
          final List<int> bytes = document.saveSync();
          setState(() {
            _documentBytes = Uint8List.fromList(bytes);
          });
       }
    }
  }

}
