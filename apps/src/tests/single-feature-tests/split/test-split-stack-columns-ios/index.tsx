import React, { useCallback, useRef, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Split, Stack } from 'react-native-screens';
import { createScenario } from '@apps/tests/shared/helpers';
import { Button } from '@apps/shared/Button';
import { scenarioDescription } from './scenario-description';

type ColumnName = 'primary' | 'secondary';

interface ScreenModel {
  key: string;
  activityMode: 'attached' | 'detached';
}

const COLUMNS: ColumnName[] = ['primary', 'secondary'];

const COLUMN_TITLES: Record<ColumnName, string> = {
  primary: 'Primary',
  secondary: 'Secondary',
};

const COLUMN_COLORS: Record<ColumnName, string> = {
  primary: '#e8f0fe',
  secondary: '#fde8e8',
};

/**
 * POC: a `Stack.Host` mounted directly in a `Split.Column` runs on the column's
 * own navigation controller, so every column gets its own stack and header.
 */
function TestSplitStackColumns() {
  const [screens, setScreens] = useState<Record<ColumnName, ScreenModel[]>>({
    primary: [{ key: 'primary-1', activityMode: 'attached' }],
    secondary: [{ key: 'secondary-1', activityMode: 'attached' }],
  });
  const nextIndex = useRef(2);

  const push = useCallback((column: ColumnName) => {
    const key = `${column}-${nextIndex.current++}`;
    setScreens(current => ({
      ...current,
      [column]: [...current[column], { key, activityMode: 'attached' }],
    }));
  }, []);

  const pop = useCallback((column: ColumnName) => {
    setScreens(current => {
      const attached = current[column].filter(
        screen => screen.activityMode === 'attached',
      );
      if (attached.length <= 1) {
        return current;
      }
      const top = attached[attached.length - 1];
      return {
        ...current,
        [column]: current[column].map(screen =>
          screen.key === top.key
            ? { ...screen, activityMode: 'detached' }
            : screen,
        ),
      };
    });
  }, []);

  const remove = useCallback((column: ColumnName, key: string) => {
    setScreens(current => ({
      ...current,
      [column]: current[column].filter(screen => screen.key !== key),
    }));
  }, []);

  return (
    <Split.Host preferredDisplayMode="oneBesideSecondary">
      {COLUMNS.map(column => (
        <Split.Column key={column}>
          <Stack.Host>
            {screens[column].map((screen, index) => (
              <Stack.Screen
                key={screen.key}
                screenKey={screen.key}
                activityMode={screen.activityMode}
                onDismiss={key => remove(column, key)}
                onNativeDismiss={key => remove(column, key)}>
                <Stack.HeaderConfig
                  title={`${COLUMN_TITLES[column]} ${index + 1}`}
                  ios={{ largeTitleEnabled: index === 0 }}
                />
                {/* Fixed top padding instead of SafeAreaView: stack screens are not
                    safe area providers yet, so the column's navigation bar would not
                    be accounted for. Out of scope of the POC. */}
                <View
                  style={[
                    styles.content,
                    { backgroundColor: COLUMN_COLORS[column] },
                  ]}>
                  <Text style={styles.screenKey}>{screen.key}</Text>
                  <Button title="Push" onPress={() => push(column)} />
                  <Button title="Pop" onPress={() => pop(column)} />
                </View>
              </Stack.Screen>
            ))}
          </Stack.Host>
        </Split.Column>
      ))}
    </Split.Host>
  );
}

const styles = StyleSheet.create({
  content: {
    flex: 1,
    paddingTop: 160,
    paddingHorizontal: 12,
    gap: 4,
  },
  screenKey: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 8,
  },
});

export default createScenario(TestSplitStackColumns, scenarioDescription);
