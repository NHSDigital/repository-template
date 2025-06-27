import { handler } from '../index';
import type { Context } from 'aws-lambda';
import { mockDeep } from 'jest-mock-extended';

describe('event-logging Lambda', () => {
  it('logs the input event and returns 200', async () => {
    const event = { foo: 'bar' };
    const context = mockDeep<Context>();
    const callback = jest.fn();
    const result = await handler(event, context, callback);

    expect(result).toEqual({
      statusCode: 200,
      body: 'Event logged',
    });
  });
});
