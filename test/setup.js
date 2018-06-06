// Enzyme React 16 configuration
import Adapter from 'enzyme-adapter-react-16';
import { configure } from 'enzyme';

configure({ adapter: new Adapter() });


// Prevent Mocha from compiling resources like css, scss or svg
function disableOnTest() {
  return null;
}

require.extensions['.css'] = disableOnTest;
require.extensions['.scss'] = disableOnTest;
require.extensions['.svg'] = disableOnTest;
