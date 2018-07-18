import _ from 'underscore';
import { scaleLinear, scaleTime } from 'd3-scale';
import { line, area, curveLinear } from 'd3-shape';
import { extent, max, sum } from 'd3-array';
import { timeMinute } from 'd3-time';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

const d3 = {
  scaleLinear,
  scaleTime,
  line,
  area,
  curveLinear,
  extent,
  max,
  timeMinute,
  sum,
};

const defaultColorPalette = {
  blue: ['#1f78d1', '#8fbce8'],
  orange: ['#fc9403', '#feca81'],
  red: ['#db3b21', '#ed9d90'],
  green: ['#1aaa55', '#8dd5aa'],
  purple: ['#6666c4', '#d1d1f0'],
};

const defaultColorOrder = ['blue', 'orange', 'red', 'green', 'purple'];

const defaultStyleOrder = ['solid', 'dashed', 'dotted'];

function queryTimeSeries(query, graphWidth, graphHeight, graphHeightOffset, xDom, yDom, lineStyle) {
  let usedColors = [];
  let renderCanary = false;
  const timeSeriesParsed = [];

  function pickColor(name) {
    let pick;
    if (name && defaultColorPalette[name]) {
      pick = name;
    } else {
      const unusedColors = _.difference(defaultColorOrder, usedColors);
      if (unusedColors.length > 0) {
        [pick] = unusedColors;
      } else {
        usedColors = [];
        [pick] = defaultColorOrder;
      }
    }
    usedColors.push(pick);
    return defaultColorPalette[pick];
  }

  query.result.forEach((timeSeries, timeSeriesNumber) => {
    let metricTag = '';
    let lineColor = '';
    let areaColor = '';
    let shouldRenderLegend = true;
    const timeSeriesValues = timeSeries.values.map(d => d.value);
    const maximumValue = d3.max(timeSeriesValues);
    const accum = d3.sum(timeSeriesValues);
    const trackName = capitalizeFirstCharacter(query.track ? query.track : 'Stable');

    if (trackName === 'Canary') {
      renderCanary = true;
    }

    const timeSeriesScaleX = d3.scaleTime().range([0, graphWidth - 70]);

    const timeSeriesScaleY = d3.scaleLinear().range([graphHeight - graphHeightOffset, 0]);

    timeSeriesScaleX.domain(xDom);
    timeSeriesScaleX.ticks(d3.timeMinute, 60);
    timeSeriesScaleY.domain(yDom);

    const defined = d => !Number.isNaN(d.value) && d.value != null;

    const lineFunction = d3
      .line()
      .defined(defined)
      .curve(d3.curveLinear) // d3 v4 uses curbe instead of interpolate
      .x(d => timeSeriesScaleX(d.time))
      .y(d => timeSeriesScaleY(d.value));

    const areaFunction = d3
      .area()
      .defined(defined)
      .curve(d3.curveLinear)
      .x(d => timeSeriesScaleX(d.time))
      .y0(graphHeight - graphHeightOffset)
      .y1(d => timeSeriesScaleY(d.value));

    const timeSeriesMetricLabel = timeSeries.metric[Object.keys(timeSeries.metric)[0]];
    const seriesCustomizationData =
      query.series != null && _.findWhere(query.series[0].when, { value: timeSeriesMetricLabel });

    if (seriesCustomizationData) {
      metricTag = seriesCustomizationData.value || timeSeriesMetricLabel;
      [lineColor, areaColor] = pickColor(seriesCustomizationData.color);
      shouldRenderLegend = false;
    } else {
      metricTag = timeSeriesMetricLabel || query.label || `series ${timeSeriesNumber + 1}`;
      [lineColor, areaColor] = pickColor();
      if (timeSeriesParsed.length > 1) {
        shouldRenderLegend = false;
      }
    }

    if (!shouldRenderLegend) {
      if (!timeSeriesParsed[0].tracksLegend) {
        timeSeriesParsed[0].tracksLegend = [];
      }
      timeSeriesParsed[0].tracksLegend.push({
        max: maximumValue,
        average: accum / timeSeries.values.length,
        lineStyle,
        lineColor,
        metricTag,
      });
    }

    timeSeriesParsed.push({
      linePath: lineFunction(timeSeries.values),
      areaPath: areaFunction(timeSeries.values),
      timeSeriesScaleX,
      timeSeriesScaleY,
      values: timeSeries.values,
      max: maximumValue,
      average: accum / timeSeries.values.length,
      lineStyle,
      lineColor,
      areaColor,
      metricTag,
      trackName,
      shouldRenderLegend,
      renderCanary,
    });
  });

  return timeSeriesParsed;
}

export default function createTimeSeries(queries, graphWidth, graphHeight, graphHeightOffset) {
  const allValues = queries.reduce(
    (allQueryResults, query) =>
      allQueryResults.concat(
        query.result.reduce((allResults, result) => allResults.concat(result.values), []),
      ),
    [],
  );

  const xDom = d3.extent(allValues, d => d.time);
  const yDom = [0, d3.max(allValues.map(d => d.value))];

  return queries.reduce((series, query, index) => {
    const lineStyle = defaultStyleOrder[index % defaultStyleOrder.length];
    return series.concat(
      queryTimeSeries(query, graphWidth, graphHeight, graphHeightOffset, xDom, yDom, lineStyle),
    );
  }, []);
}
