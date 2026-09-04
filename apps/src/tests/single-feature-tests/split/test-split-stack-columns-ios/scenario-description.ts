import type { ScenarioDescription } from '@apps/tests/shared/helpers';

export const scenarioDescription: ScenarioDescription = {
  name: 'Split with Stack columns (iOS, POC)',
  key: 'test-split-stack-columns-ios',
  details:
    'Stack v5 hosted directly in Split columns: each column runs its own stack with a header on the column navigation bar.',
  platforms: ['ios'],
  e2eCoverage: 'tbd',
  smokeTest: false,
};
