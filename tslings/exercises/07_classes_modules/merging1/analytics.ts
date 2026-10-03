// merging1 — see host.ts for the explanation.
//

import { register } from './host.ts';

export interface Analytics {
  events: string[];
  track(event: string): void;
}

const analytics: Analytics = {
  events: [],
  track(event) {
    this.events.push(event);
  },
};

register('analytics', analytics);
