import React from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { LogsWithTasks, useLogs } from '../stores/useStatsStore';

const HOUR_HEIGHT = 120;

const getLogPosition = (log: LogsWithTasks) => {
  const startTime = new Date(log.start_time);
  const endTime = new Date(log.end_time);
  const startPercentage =
    ((startTime.getHours() + startTime.getMinutes() / 60) / 24) * 100;
  const endPercentage =
    ((endTime.getHours() + endTime.getMinutes() / 60) / 24) * 100;
  return {
    start: `${startPercentage}%`,
    height: `${endPercentage - startPercentage}%`,
  };
};

export default function ScheduleChart() {
  const logs = useLogs() ?? [];
  const hours = Array.from({ length: 25 }, (_, i) => i);

  return (
    <ScrollView
      style={styles.scrollView}
      showsVerticalScrollIndicator={false}
      contentOffset={{ y: (24 * HOUR_HEIGHT) / 3 }}
    >
      <View style={styles.chart}>
        {hours.map((hour) => (
          <View key={hour} style={styles.hourRow}>
            <Text
              style={styles.hourText}
            >{`${hour.toString().padStart(2, '0')}:00`}</Text>
            <View style={styles.hourLine} />
          </View>
        ))}
        {logs.map((log) => (
          <View
            key={log.id}
            style={[
              styles.logItem,
              {
                top: getLogPosition(log).start,
                height: getLogPosition(log).height,
              },
            ]}
          ></View>
        ))}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  header: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'center',
    width: '100%',
  },
  displayTime: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  scrollView: {
    flex: 1,
    paddingHorizontal: 20,
  },
  chart: {
    position: 'relative',
    height: 24 * HOUR_HEIGHT,
    marginVertical: 20,
  },
  hourRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    height: HOUR_HEIGHT,
  },
  hourText: {
    width: 50,
    fontSize: 12,
    transform: [{ translateY: -6 }],
    color: '#FFFFFF',
  },
  hourLine: {
    flex: 1,
    height: 1,
    backgroundColor: '#3F3E55',
  },
  logItem: {
    position: 'absolute',
    left: 50,
    right: 0,
    borderRadius: 8,
    backgroundColor: '#DBBFFF',
  },
});