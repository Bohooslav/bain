require 'imba-router'

import {Bible} from './Bible'
import {Profile} from './Profile'

export tag Site

  def render
    <self>
      <Bible route='/'>
      <Profile route='/profile'>
