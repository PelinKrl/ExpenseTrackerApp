import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/barGraph/individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph({
    super.key,
    required this.monthlySummary,
    required this.startMonth,
    });

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {

  //hold the data for each bar
  List<IndividualBar> barData =[];

  @override
  void initState() {    
    super.initState();

    //scroll to end auto
    WidgetsBinding.instance.addPostFrameCallback((Timestamp)=> scrollToEnd());
  }

  //initialize bar data -- use our monthly summary to create a list of bars
  void initializeBarData(){
    barData = List.generate(widget.monthlySummary.length,(index)=>IndividualBar(
      x: index,
      y: widget.monthlySummary[index]
      ),
    );
  }

  //calculate max for upper limit of the grap
  double calculateMax(){
    //initialy set to 1000
    double max=1000;

    //get the month with highest amount
    widget.monthlySummary.sort();
    //increase the upper limit by a bit
    max=widget.monthlySummary.last*1.05;

    if(max<1000){
      return 1000;
    }
    return max;
  }


 //scroll controller to make sure it scrolls to the latest month
 final ScrollController _scrollController =ScrollController();
 void scrollToEnd(){
  _scrollController.animateTo(_scrollController.position.maxScrollExtent,duration:const Duration(seconds: 1),curve: Curves.fastOutSlowIn );
 }

 
  @override
  Widget build(BuildContext context) {

    //initialize upon build
    initializeBarData();

    //bar dimension sizes
    double barWidth=20;
    double spaceBetweenBars=15;



    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          width: barWidth*barData.length + spaceBetweenBars *(barData.length-1),
          child: BarChart(
            BarChartData(
              minY:0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,getTitlesWidget: getBottomTitles,
                reservedSize: 30,
                ),
                ),
              ),
              barGroups: barData.map((data)=>BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(toY: data.y,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.purple,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: calculateMax(),
                    color: Colors.white
                  ),
                  ),
                ],
          
                ),
                ).toList(),
              alignment:BarChartAlignment.center,
              groupsSpace: spaceBetweenBars,
            ),
          ),
        ),
      ),
    );
  }


  //BOTTOM TITLES
    Widget getBottomTitles(double value,TitleMeta meta){
      const textStyle = TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );

      int monthIndex = (widget.startMonth - 1 + value.toInt()) % 12;


      String text;
      switch(monthIndex){
        case 0:
          text = 'J';
          break;
        case 1:
          text = 'F';
          break;
        case 2:
          text = 'M';
          break;
        case 3:
          text = 'A';
          break;
        case 4:
          text = 'M';
          break;
        case 5:
          text = 'J';
          break;
        case 6:
          text = 'J';
          break;
        case 7:
          text = 'A';
          break;
        case 8:
          text = 'S';
          break;
        case 9:
          text = 'O';
          break;
        case 10:
          text = 'N';
          break;
        case 11:
          text = 'D';
          break;
        default:
          text ='';
          break;
      }
      return SideTitleWidget(child: Text(text,style:textStyle), axisSide: meta.axisSide);
    }

}

